import 'dart:math' as math;
import 'package:doc_sync/features/authentication/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimatedTextLoader extends StatelessWidget {
  const AnimatedTextLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    const appName = "D O C  S Y N C";
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        appName.length,
        (index) => AnimatedBuilder(
          animation: controller.letterAnimation,
          builder: (context, child) {
            // Staggered animation for each letter
            final delay = index / appName.length;
            final animValue = controller.letterAnimation.value;
            final position = (animValue - delay) * 2;
            
            // Improve wave animation with smoother curve
            double scale = 1.0;
            double opacity = 1.0;
            
            if (position >= 0 && position <= 1.0) {
              // Wave effect using sine function
              scale = 1.0 + 0.3 * math.sin(position * math.pi);
              
              // Fade in for initial appearance
              if (controller.letterAnimController.status == AnimationStatus.forward) {
                opacity = position < 0.5 ? position * 2 : 1.0;
              }
            }
                
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    appName[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}