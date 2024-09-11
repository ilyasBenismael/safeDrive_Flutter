import 'package:safe_drive/models/detection.dart';
import 'dart:convert';

class AlertService {

   static String myData = ''' [
      { "class_id": 0, "confidence": 0.92, "depth": 3.0, "bounding_box": { "x_center": 0.3, "y_center": 0.7, "width": 0.1, "height": 0.2 } }, // Car behind the original car
      { "class_id": 0, "confidence": 0.88, "depth": 2.0, "bounding_box": { "x_center": 0.8, "y_center": 0.2, "width": 0.15, "height": 0.25 } }, // Car in front of the original car
      { "class_id": 1, "confidence": 0.75, "depth": 2.2, "bounding_box": { "x_center": 0.1, "y_center": 0.6, "width": 0.05, "height": 0.1 } }, // Bike on the left side
      { "class_id": 1, "confidence": 0.80, "depth": 2.4, "bounding_box": { "x_center": 0.9, "y_center": 0.6, "width": 0.05, "height": 0.1 } }, // Bike on the right side
      { "class_id": 2, "confidence": 0.95, "depth": 1.8, "bounding_box": { "x_center": 0.5, "y_center": 0.4, "width": 0.08, "height": 0.2 } }, // Pedestrian crossing the street
      { "class_id": 2, "confidence": 0.87, "depth": 2.1, "bounding_box": { "x_center": 0.3, "y_center": 0.2, "width": 0.08, "height": 0.2 } }, // Pedestrian on the sidewalk
      { "class_id": 3, "confidence": 0.90, "depth": 3.5, "bounding_box": { "x_center": 0.2, "y_center": 0.8, "width": 0.1, "height": 0.1 } }, // Stop sign on the left side
      { "class_id": 3, "confidence": 0.92, "depth": 3.5, "bounding_box": { "x_center": 0.8, "y_center": 0.8, "width": 0.1, "height": 0.1 } }, // Stop sign on the right side
      { "class_id": 4, "confidence": 0.85, "depth": 3.0, "bounding_box": { "x_center": 0.5, "y_center": 0.9, "width": 0.2, "height": 0.1 } }, // Crosswalk sign in the middle
      { "class_id": 0, "confidence": 0.78, "depth": 3.2, "bounding_box": { "x_center": 0.7, "y_center": 0.3, "width": 0.12, "height": 0.2 } }, // Car parked on the side
      { "class_id": 0, "confidence": 0.82, "depth": 2.8, "bounding_box": { "x_center": 0.2, "y_center": 0.3, "width": 0.12, "height": 0.2 } }, // Car parked on the side
      { "class_id": 1, "confidence": 0.65, "depth": 2.5, "bounding_box": { "x_center": 0.5, "y_center": 0.1, "width": 0.05, "height": 0.1 } }, // Bike parked on the sidewalk
      { "class_id": 2, "confidence": 0.90, "depth": 1.9, "bounding_box": { "x_center": 0.1, "y_center": 0.4, "width": 0.08, "height": 0.2 } }, // Pedestrian talking on the phone
      { "class_id": 2, "confidence": 0.88, "depth": 2.0, "bounding_box": { "x_center": 0.9, "y_center": 0.4, "width": 0.08, "height": 0.2 } }, // Pedestrian carrying a bag
      { "class_id": 0, "confidence": 0.85, "depth": 3.0, "bounding_box": { "x_center": 0.5, "y_center": 0.7, "width": 0.1, "height": 0.2 } } // Another car in the background
  ] ''';


  static List<Detection> parseDetections(String jsonStr) {
    //the json decode turn the string to dart formats
    final List<dynamic> jsonList = json.decode(jsonStr);
    //for each jsonItem we make a detection objct
    return jsonList.map((jsonItem) => Detection.fromJson(jsonItem)).toList();
  }



  static void showDetection(){
    List<Detection> listo= parseDetections(myData);
    print(listo[2]);
  }







}