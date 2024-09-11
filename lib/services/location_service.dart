import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';


class LocationService {
  final BuildContext context;

  LocationService(this.context);


////////////////////////////////////////// CHECK LOCATION PERMISSION //////////////////////////////////////////////

  //for each case show msg, and return 1 only if all is permitted
  Future<int> checkPermissions() async {
    try {
      bool locationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationEnabled) {
        _toastMsg('You need to activate the location');
        return -1;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _toastMsg('You need to give permission for location access');
        return -2;
      } else {
        return 1;
      }
    } catch (e) {
      _toastMsg('Error while getting location permission');
      return -3;
    }
  }



///////////////////////////////////////////////// SETTING UP SPEED /////////////////////////////////////////////////

  //we return 1 if all good
  Future<int> setUpSpeed(Function(double) onSpeedChanged) async {
    int permissionStatus = await checkPermissions();
    if (permissionStatus != 1) {
      return permissionStatus;
    }

    //if it's not android it won't work, we make a 3sec speed update
    if (defaultTargetPlatform == TargetPlatform.android) {
      Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 3),
        ),
      ).listen((Position position) {
        onSpeedChanged(position.speed * 3.6); // Speed in km/h
      });
      return 1;
    } else {
      _toastMsg('Not an Android platform');
      return -1;
    }
  }

  void _toastMsg(String msg) {
    final snackBar = SnackBar(content: Text(msg));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}


//   ////////////////////////////////////////// CHECK LOCATION PERMISSION //////////////////////////////////////////////
//
//   //we show msgs for each case and return 1 only if all is good
//   Future<int> _checkPermissions() async {
//     try {
//       //-1 if location isn't activated
//       bool locationEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!mounted) {
//         return -5;
//       }
//       if (!locationEnabled) {
//         _toastMsg(context, 'u need to activate the location');
//         return -1;
//       }
//       //-2 if location is not permited
//       LocationPermission permission = await Geolocator.requestPermission();
//       if (!mounted) {
//         return -5;
//       }
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         _toastMsg(context, 'u need to give permission for location access');
//         return -2;
//       } else {
//         return 1;
//       }
//     } catch (e) {
//       print(e);
//       _toastMsg(context, 'error while getting location permission');
//       return -3;
//     }
//   }
//
//   ///////////////////////////////////////////////// SETTING UP SPEED /////////////////////////////////////////////////
//
//   Future<int> _setUpSpeed() async {
//     try {
//       //recheck permissions, if != 1 permission not good
//       int a = await _checkPermissions();
//       if (a != 1 || !mounted) {
//         return -1;
//       }
//
//       //we are sibling android, we set up the position stream with good accuracy
//       //and duration of 3secs for location update (on which speed var is based)
//       if (defaultTargetPlatform == TargetPlatform.android) {
//         Geolocator.getPositionStream(
//                 locationSettings: AndroidSettings(
//                     accuracy: LocationAccuracy.bestForNavigation,
//                     forceLocationManager: true,
//                     intervalDuration: const Duration(seconds: 3)))
//             .listen((Position position) {
//           setState(() {
//             _speed = position.speed * 3.6; // Speed in meters/second
//           });
//         });
//         return 1;
//       } else {
//         _toastMsg(context, 'not android platform');
//         return -1;
//       }
//     } catch (e) {
//       _toastMsg(context, 'error while setting up speed');
//       print(e);
//       return -1;
//     }
//   }
