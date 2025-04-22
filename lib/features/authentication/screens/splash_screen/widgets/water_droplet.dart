import 'package:flutter/material.dart';

class WaterDroplet extends StatelessWidget {
  final double size;
  final Color color;
  final double? stretchFactor;

  const WaterDroplet({
    super.key,
    this.size = 30.0,
    this.color = const Color(0xFF2A5781),
    this.stretchFactor,
  });

  @override
  Widget build(BuildContext context) {
    // return RotatedBox(
    //   quarterTurns: 2,
    //   child: CustomPaint(
    //     size: Size(size, size * (stretchFactor ?? 1.5)),
    //     painter: _WaterDropletPainter(
    //       color: color,
    //       stretchFactor: stretchFactor,
    //     ),
    //   ),
    // );

    return Container(
      width: size,
      height: size * (stretchFactor ?? 1.5),
      decoration: BoxDecoration(
        color: color,
        // borderRadius: BorderRadius.circular(12),
        shape: BoxShape.circle
      ),
    );
  }
}

// class _WaterDropletPainter extends CustomPainter {
//   final Color color;
//   final double? stretchFactor;

//   _WaterDropletPainter({required this.color, this.stretchFactor});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final stretch = stretchFactor ?? 1.5;
//     final paint =
//         Paint()
//           ..color = color
//           ..style = PaintingStyle.fill;

//     final path = Path();

//     // Calculate dimensions
//     final width = size.width;
//     final height = size.height;
//     final centerX = width / 2;

//     // Draw the droplet teardrop shape
//     path.moveTo(centerX, 0);

//     // Top left curve
//     path.quadraticBezierTo(0, height * 0.3, centerX, height);

//     // Top right curve
//     path.quadraticBezierTo(width, height * 0.3, centerX, 0);

//     path.close();
//     canvas.drawPath(path, paint);

//     // Add highlight for 3D effect
//     final highlightPaint =
//         Paint()
//           ..color = Colors.white.withValues(alpha: 0.4)
//           ..style = PaintingStyle.fill;

//     final highlightPath = Path();
//     highlightPath.moveTo(centerX, 0);
//     highlightPath.quadraticBezierTo(
//       width * 0.3,
//       height * 0.2,
//       width * 0.4,
//       height * 0.5,
//     );
//     highlightPath.quadraticBezierTo(width * 0.35, height * 0.2, centerX, 0);

//     canvas.drawPath(highlightPath, highlightPaint);
//   }

//   @override
//   bool shouldRepaint(_WaterDropletPainter oldDelegate) =>
//       color != oldDelegate.color || stretchFactor != oldDelegate.stretchFactor;
// }
