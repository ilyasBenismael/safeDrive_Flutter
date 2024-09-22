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


///////////////////////////////////////////// IMAGE CAPTURE ////////////////////////////////////////////////////

//we capture image, compress it, make it cubic, and turn it back in the imagecptured function
  void captureImage(Function(Uint8List) onImageCaptured) async {
    try {
      final image = await _cameraController.takePicture();
      Uint8List? bitesImage = await _compressImage(image);
      Uint8List cubicImage = await makeImageCubic(bitesImage!);
      onImageCaptured(cubicImage);
      } catch (e) {
      print("Error taking picture: $e");
    }
  }


///////////////////////////////////////////// COMPRESS IMAGE ////////////////////////////////////////////////////

  Future<Uint8List?> _compressImage(XFile image) async {
    Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
      image.path,
      quality: 70,
    );
    return compressedImage;
  }




  //this will be called when disposed to cancel all this
  void dispose() {
    _timer?.cancel();
    _cameraController.dispose();
  }


  // Function to crop the image to a square (cubic)
  Uint8List makeImageCubic(Uint8List imageBytes)  {
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



