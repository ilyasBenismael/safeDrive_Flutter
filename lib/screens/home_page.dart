import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double _speed = 0.0;
  late Future<int> cameraAndLocationState;
  Uint8List? _image;
  late CameraService _cameraService;
  late LocationService _locationService;
  String detectedObjcts = 'loading';
  String errorMsg = '';
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _locationService = LocationService(context);
    cameraAndLocationState = setUpEverything();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Drive'),
        backgroundColor: Colors.black87,
      ),
      body: FutureBuilder(
        future: cameraAndLocationState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == 1) {
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      detectedObjcts,
                      style:
                          const TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      height: 400,
                      width: 400,
                      color: Colors.black,
                      child: _image != null
                          ? Image.memory(_image!, fit: BoxFit.contain)
                          : const Text('Loading'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${_speed.toStringAsFixed(2)} km/h',
                        style: const TextStyle(
                            fontSize: 24, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(errorMsg),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: retry,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Retry'),
                  )
                ]));
          }
        },
      ),
    );
  }


////////////////////////////////////////////// END OF BUILD ////////////////////////////////////////////////////////




///////////////////////////////////////////// SETUPEVERYTHING ////////////////////////////////////////////////////////

  Future<int> setUpEverything() async {
    try {
      //run up speed, if error return
      int speedStatus = await _locationService.setUpSpeed((speed) {
        setState(() {
          _speed = speed;
        });
      });
      if (speedStatus != 1) {
        setState(() {
          errorMsg =
              "Location Problem";
        });
        return -1;
      }

      //setting up the channel
      channel = WebSocketChannel.connect(
          Uri.parse("wss://safedrivefastapi-production.up.railway.app/ws"));

      //???check channel

      //set up camera, if error return
      int a = await _cameraService.setUpCamera();
      if (a != 1) {
        setState(() {
          errorMsg = "camera setup prob";
        });
        return -2;
      }

      //setup the listenning and captureimage response each time
      setUpCommunicationWithFastApi(channel);

      //initiate connection with the first image
      _cameraService.captureImage((compressedImage) {
        channel.sink.add(compressedImage);
      });

      //if all good with no error we return
      return 1;
    } catch (e) {
      setState(() {
        detectedObjcts = "error : ${e.toString()}";
      });
      return -3;
    }
  }




  ///////////////////////////////////// SETUP_COMMUNICATION_TO_FASTAPI ////////////////////////////////////////////////

  void setUpCommunicationWithFastApi(WebSocketChannel channel) {
    //whenever I get the rendered image from server, we show it and send back a new one,
    //if error or disconnection we show the msg
    channel.stream.listen(
      (message) {
        if (message is List<int>) {
          setState(() {
            _image = Uint8List.fromList(message);
          });
          _cameraService.captureImage((compressedImage) {
            channel.sink.add(compressedImage);
            setState(() {
              detectedObjcts = "New Detection In progress...";
            });
          });
        } else {
          setState(() {
            detectedObjcts = "error : rendered image wasn't received";
          });
        }
      },
      onError: (error) {
        setState(() {
          detectedObjcts = "error : $error";
        });
      },
      onDone: () {
        setState(() {
          detectedObjcts = "Disconnected to server";
        });
      },
    );
  }



  //////////////////////////////////////////////// RETRY /////////////////////////////////////////////////////////////

  void retry() {
    //reset();
    cameraAndLocationState = setUpEverything();
  }







//////////////////////////////////////////////// RESET /////////////////////////////////////////////////////////////

  void reset() {
    _cameraService.dispose();
    //???cancel location stream
    //???cancel channel stream and close connection
    detectedObjcts = 'Loading';
    errorMsg = "";
  }







}
