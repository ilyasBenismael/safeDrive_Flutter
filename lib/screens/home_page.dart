import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _speed = 0.0;
  String oldPosition = '';
  String newPosition = '';
  late Future<int> cameraAndLocationState;
  late CameraController _controller;
  Uint8List? _image;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    cameraAndLocationState = setUpEverything();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: FutureBuilder(
        future: cameraAndLocationState,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == 1) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_image != null)

                  const SizedBox(height: 15),
                  Text(
                    '$_speed km/h',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    newPosition,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    oldPosition,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError || snapshot.data != 1) {
            return Center(
              child: const Text(
                'Error occurred or data not valid',
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            );
          } else {
            return const Center(child: Text('Unexpected state'));
          }
        },
      ),
    );
  }

  ////////////////////////////////////////////// END OF BUILD MTHD /////////////////////////////////////////////////

















  ///////////////////////////////////////////////// SETTING UP ALL /////////////////////////////////////////////////

  Future<int> setUpEverything() async{
    int a = await setUpCamera();
    int b = await _setUpSpeed();
    if(a == 1 && b ==1){
      return 1;
    }else{
      return -1;
    }
  }











///////////////////////////////////////////// SETUP CAMERA ////////////////////////////////////////////////////

  Future<int> setUpCamera() async {
    try {
      //get available cameras and choose the rear camera
      final cameras = await availableCameras();
      final rearCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      //make the camera controller and initialize it
      _controller = CameraController(
        rearCamera,
        ResolutionPreset.medium,
      );
      await _controller.initialize();
      if(!mounted){return -5;}
      //make timer where we take a pic every second
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        try {
          final image = await _controller.takePicture();
          // Compress the image
          Uint8List? compressedImage = await _compressImage(image);
          if(!mounted){return;}
          // Update the state with the compressed image data
          setState(() {
            _image = compressedImage;
          });
        } catch (e) {
          print(e);
          _toastMsg(context, "Error taking picture");
        }
      }); //if timer is set and all good return 1
      return 1;
    } catch (e) {
      _toastMsg(context, "Error initializing camera");
      return -1;
    }
  }










  ///////////////////////////////////////////// COMPRESS IMAGE ////////////////////////////////////////////////////

  Future<Uint8List?> _compressImage(XFile image) async {
    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 50,
    );
    return compressedImage;
  }















  

  ////////////////////////////////////////// CHECK LOCATION PERMISSION //////////////////////////////////////////////

  //we show msgs for each case and return 1 only if all is good
  Future<int> _checkPermissions() async {
    try {
      //-1 if location isn't activated
      bool locationEnabled = await Geolocator.isLocationServiceEnabled();
      if(!mounted){return -5;}
      if(!locationEnabled){
        _toastMsg(context, 'u need to activate the location');
        return -1;
      }
      //-2 if location is not permited
      LocationPermission permission = await Geolocator.requestPermission();
      if(!mounted){return -5;}
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _toastMsg(context, 'u need to give permission for location access');
        return -2;
      } else {
        return 1;
      }
    } catch (e) {
      print(e);
      _toastMsg(context, 'error while getting location permission');
      return -3;
    }
  }










  ///////////////////////////////////////////////// SETTING UP SPEED /////////////////////////////////////////////////

  Future<int> _setUpSpeed() async {
    try {
      //recheck permissions, if != 1 permission not good
      int a = await _checkPermissions();
      if (a != 1 && !mounted) {
        return -1;
      }

      //we are sibling android, we set up the position stream with good accuracy
      //and duration of 3secs for location update (on which speed var is based)
      if (defaultTargetPlatform == TargetPlatform.android) {
        Geolocator.getPositionStream(
                locationSettings: AndroidSettings(
                    accuracy: LocationAccuracy.bestForNavigation,
                    forceLocationManager: true, //use old tool that
                    intervalDuration: const Duration(
                        seconds: 3)))
            .listen((Position position) {
          setState(() {
            _speed = position.speed * 3.6; // Speed in meters/second
          });
        });
        return 1;
      }else{
        _toastMsg(context,'not android platform');
        return -1;
      }
    } catch (e) {
      _toastMsg(context,'error while setting up speed');
      print(e);
      return -1;
    }
  }







  //////////////////////////////////////////////// TOAST MSG ////////////////////////////////////////////////////////

  void _toastMsg(BuildContext context, String msg) {
    if (!mounted) {
      return;
    }
    final snackBar = SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }









}
