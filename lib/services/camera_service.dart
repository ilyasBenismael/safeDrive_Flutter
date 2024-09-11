import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;


class CameraService {
  late CameraController _cameraController;
  Timer? _timer;



/////////////////////////////////////////////// SETUP CAMERA ////////////////////////////////////////////////////

  //return 1 only if setup is good
  Future<int> setUpCamera() async {
    try {
      //get available cameras and choose the rear camera
      final cameras = await availableCameras();
      final rearCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      //make the camera controller and initialize it
      _cameraController = CameraController(
        rearCamera,
        ResolutionPreset.medium,
      );
      await _cameraController.initialize();
      await _cameraController.setFlashMode(FlashMode.off);
      return 1;
    } catch (e) {
      print("Error initializing camera: $e");
      return -1;
    }
  }



  /////////////////////////////////////////////////// IMAGE CAPTURE ////////////////////////////////////////////////////


  //the onImageCaptured() is a mthd we called from frontend that gets executed in this timer
  void startImageCapture(Function(Uint8List) onImageCaptured) {
    //after the setup is good wa make this timer that takes a pic, compress it then use it
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      try {
        final image = await _cameraController.takePicture();
        Uint8List? compressedImage = await _compressImage(image);
        if (compressedImage != null) {
          Uint8List cubicImage = await makeImageCubic(compressedImage);
          onImageCaptured(cubicImage);
        }
      } catch (e) {
        print("Error taking picture: $e");
      }
    });
  }






  ///////////////////////////////////////////// COMPRESS IMAGE ////////////////////////////////////////////////////


  Future<Uint8List?> _compressImage(XFile image) async {
    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 50,
    );
    return compressedImage;
  }



  //this will be called when disposed to cancel all this
  void dispose() {
    _timer?.cancel();
    _cameraController.dispose();
  }



  // Function to crop the image to a square (cubic)
  Future<Uint8List> makeImageCubic(Uint8List imageBytes) async {
    // Decode the image from bytes
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception("Could not decode the image");
    }

    int width = originalImage.width;
    int height = originalImage.height;

    // Determine the size of the square
    int squareSize = width < height ? width : height;

    // Calculate the starting x and y coordinates for cropping
    int xOffset = (width - squareSize) ~/ 2;
    int yOffset = (height - squareSize) ~/ 2;

    // Crop the image to the square
    img.Image croppedImage = img.copyCrop(
      originalImage,
      x: xOffset,
      y: yOffset,
      width: squareSize,
      height: squareSize,
    );

    // Encode the cropped image back to Uint8List
    Uint8List cubicImageBytes = Uint8List.fromList(img.encodeJpg(croppedImage));

    return cubicImageBytes;
  }



}



