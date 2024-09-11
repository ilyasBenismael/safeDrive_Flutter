import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safe_drive/services/alert_service.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // double _speed = 0.0;
  // late Future<int> cameraAndLocationState;
  // Uint8List? _image;
  // late CameraService _cameraService;
  // late LocationService _locationService;
  String detectedObjcts = 'loading';

  @override
  void initState() {
    super.initState();
    // _cameraService = CameraService();
    // _locationService = LocationService(context);
    // cameraAndLocationState = setUpEverything();
    sendRequest();
  }

  @override
  void dispose() {
    // _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
          backgroundColor: Colors.black,
        ),
        body: Text(detectedObjcts)
            // FutureBuilder(
            //     future: cameraAndLocationState,
            //     builder: (context, snapshot) {
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return const Center(child: CircularProgressIndicator());
        // } else if (snapshot.hasData && snapshot.data == 1) {
        //   return Container(
        //     color: Colors.grey,
        //     child: Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: <Widget>[
        //           Container(
        //             height: 400,
        //             width: 400,
        //             color: Colors.blueGrey,
        //             child: _image != null
        //                 ? Image.memory(_image!, fit: BoxFit.contain)
        //                 : const Text('No image captured'),
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Container(
        //               child: Text(
        //                 '$_speed km/h',
        //                 style: const TextStyle(
        //                     fontSize: 24, color: Colors.white70),
        //               ),
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   );
        // } else {
        //   return Center(child: Column(
        //      mainAxisAlignment: MainAxisAlignment.center, children : [const Text('Unexpected state'), SizedBox(height: 15), ElevatedButton(
        //     onPressed: retry,
        //     style: ElevatedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        //       textStyle: const TextStyle(fontSize: 16),
        //     ),
        //     child:  const Text('Retry'),
        //   )]));
        // }
        //   },
        // ),
        );
  }

  // void retry(){
  //   cameraAndLocationState = setUpEverything();
  // }

  // Future<int> setUpEverything() async {
  //   int speedStatus = await _locationService.setUpSpeed((speed) {
  //     setState(() {
  //       _speed = speed;
  //     });
  //   });
  //   if (speedStatus == 1) {
  //     int a = await _cameraService.setUpCamera();
  //     if (a == 1) {
  //       _cameraService.startImageCapture((compressedImage) {
  //         setState(() {
  //           _image = compressedImage;
  //         });
  //       });
  //       return 1;
  //     }
  //   }
  //   return -1;
  // }


  Future<void> sendRequest() async {
    try {
      final url = Uri.parse('http://192.168.100.7:8000/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        print("goooood");
        detectedObjcts = json.decode(response.body);
        setState(() {});
        print('Response data: ${json.decode(response.body)}');
      } else {
        detectedObjcts = response.statusCode as String;
        setState(() {
          detectedObjcts = 'Request failed with status: ${response.statusCode}';
        });
      }
    } catch (e) {
      print(e);
      detectedObjcts = e.toString();
      setState(() {});
    }
  }
}
