class BoundingBox {
  final double xCenter;
  final double yCenter;
  final double width;
  final double height;

  BoundingBox({
    required this.xCenter,
    required this.yCenter,
    required this.width,
    required this.height,
  });

  // Factory constructor for creating an instance from JSON
  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      xCenter: json['x_center'],
      yCenter: json['y_center'],
      width: json['width'],
      height: json['height'],
    );
  }
}