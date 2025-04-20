// lib/loading/loading_screen.dart
import 'dart:math';
import 'dart:ui';

import 'package:doc_sync/common/widgets/loaders/widgets/animated_visual_element.dart';
import 'package:flutter/material.dart';
import 'package:doc_sync/common/widgets/loaders/widgets/animated_loading_text.dart';
import 'package:get/get.dart';

import 'package:doc_sync/features/authentication/controllers/loading_screen_controller.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoadingScreenController());
    final screenSize = MediaQuery.of(context).size;
    final double finalDiameter = controller.calculateFinalDiameter(screenSize);

    return Scaffold(
      body: Obx(() {
        // --- 1. Calculate Animation Progress ---
        final expansionProgress = Interval(
          controller.dropPhaseEnd,
          controller.expandPhaseEnd,
          curve: Curves.easeInOut,
        ).transform(controller.initialAnimationValue.value).clamp(0.0, 1.0);

        // --- 2. Calculate Current Animated Values ---
        final currentAnimatingDiameter =
            lerpDouble(
              controller.initialCircleDiameter,
              finalDiameter,
              expansionProgress,
            )!;

        final currentLogoDiameter =
            lerpDouble(
              controller.initialLogoDiameter,
              max(
                controller.initialLogoDiameter,
                currentAnimatingDiameter * 0.2,
              ),
              expansionProgress,
            )!;

        // --- 3. Determine Display Properties ---
        late double displayWidth;
        late double displayHeight;
        late BoxShape displayShape;
        BorderRadius? displayBorderRadius;
        bool needsOverflow = false;

        if (controller.showRectangle.value) {
          // Final State: Full Screen Rectangle
          displayWidth = screenSize.width;
          displayHeight = screenSize.height;
          displayShape = BoxShape.rectangle;
          displayBorderRadius = BorderRadius.zero;
        } else {
          // Animation State: Dropping or Expanding Circle
          displayWidth = currentAnimatingDiameter;
          displayHeight = currentAnimatingDiameter;
          displayShape = BoxShape.circle;
          needsOverflow =
              controller.initialAnimationValue.value >= controller.dropPhaseEnd;
        }

        // --- 4. Build the Core Animated Visual Element (using the dedicated widget) ---
        Widget visualElement = AnimatedVisualElement(
          width: displayWidth,
          height: displayHeight,
          color: controller.splashColor,
          shape: displayShape,
          borderRadius: displayBorderRadius,
          logoDiameter: currentLogoDiameter,
          logoAssetPath: controller.logoAssetPath,
          isRectangle: controller.showRectangle.value,
        );

        // --- 5. Apply OverflowBox if Necessary ---
        if (needsOverflow) {
          visualElement = OverflowBox(
            minWidth: 0.0,
            minHeight: 0.0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: visualElement,
          );
        }

        // --- 6. Build the Final Layout using Stack ---
        return Stack(
          clipBehavior: Clip.none,
          children: [
            visualElement,

            // Layer 2: Content shown AFTER animation completes
            if (controller.showRectangle.value)
              Align(
                alignment: const Alignment(0.0, 0.2),
                child: Obx(
                  () => Opacity(
                    opacity: controller.animatedTextOpacity.value,
                    child: const AnimatedLoadingText(),
                  ),
                ),
              ), // Display the animated loading text
          ],
        );
      }),
    );
  }
}
