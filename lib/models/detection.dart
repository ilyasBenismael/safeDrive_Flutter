import 'package:safe_drive/models/bounding_box.dart';


class Detection {
  final int classId;
  final double confidence;
  final double depth;
  final BoundingBox boundingBox;


  Detection({
    required this.classId,
    required this.confidence,
    required this.depth,
    required this.boundingBox,
  });

  // Factory constructor for creating an instance from JSON
  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      classId: json['class_id'],
      confidence: json['confidence'],
      depth: json['depth'],
      boundingBox: BoundingBox.fromJson(json['bounding_box']), // Convert bounding box JSON to BoundingBox instance
    );
  }
}