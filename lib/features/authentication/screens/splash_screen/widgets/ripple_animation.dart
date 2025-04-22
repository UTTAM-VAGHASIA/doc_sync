import 'package:flutter/material.dart';

class RippleAnimation extends StatelessWidget {
  final AnimationController controller;

  const RippleAnimation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Color.lerp(
              Colors.white,
              const Color(0xFF2A5781),
              controller.value,
            ),
          ),
        );
      },
    );
  }
}
