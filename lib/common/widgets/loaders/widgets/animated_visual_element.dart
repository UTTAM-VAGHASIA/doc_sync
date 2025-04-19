// lib/loading/widgets/animated_visual_element.dart
import 'package:doc_sync/common/widgets/loaders/widgets/final_content_view.dart';
import 'package:flutter/material.dart';

class AnimatedVisualElement extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final BoxShape shape;
  final BorderRadius? borderRadius; // Nullable for circle
  final double logoDiameter;
  final String logoAssetPath;
  final bool isRectangle;

  const AnimatedVisualElement({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.shape,
    this.borderRadius,
    required this.logoDiameter,
    required this.logoAssetPath, required this.isRectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: (shape == BoxShape.rectangle) ? borderRadius : null,
      ),
      child: Center(
        child: Image.asset(
          logoAssetPath,
          width: logoDiameter,
          height: logoDiameter,
          // Consider adding fit: BoxFit.contain if logo aspect ratio is not square
        ),
      ),
    );
  }
}
