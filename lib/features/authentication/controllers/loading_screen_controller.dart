// lib/features/authentication/controllers/loading_screen_controller.dart
import 'dart:developer' as dev;
import 'dart:math';
import 'package:doc_sync/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingScreenController extends GetxController
    with GetTickerProviderStateMixin {
  late AnimationController initialAnimationController;
  late AnimationController finalAnimationController;
  late Animation<AlignmentGeometry> logoAlignmentAnimation;
  late Animation<AlignmentGeometry> logoUpwardAnimation;
  late AnimationController logoUpwardAnimationController;
  late AnimationController animatedTextAnimationController;
  late Animation<double> animatedTextOpacityAnimation;

  // Configuration
  final animationDuration = const Duration(milliseconds: 1400);
  final initialCircleDiameter = 40.0;
  final initialLogoDiameter = 20.0;
  final splashColor = const Color(0xFF2A5781);
  final logoAssetPath = 'assets/logos/app-logo.png';

  // Timing intervals
  final dropPhaseEnd = 0.35;
  final expandPhaseEnd = 0.9;

  // Reactive state variables
  final showRectangle = false.obs;
  final initialAnimationValue = 0.0.obs;
  final animatedTextOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    initialAnimationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    )..addListener(() {
      initialAnimationValue.value = initialAnimationController.value;
    });

    finalAnimationController = AnimationController(
      vsync: this,
      duration: animationDuration,
    );

    logoUpwardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    animatedTextAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(
      () => animatedTextOpacity.value = animatedTextOpacityAnimation.value,
    );

    logoAlignmentAnimation = Tween<AlignmentGeometry>(
      begin: const Alignment(0.0, -1.5),
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: initialAnimationController,
        curve: Interval(0.0, dropPhaseEnd, curve: Curves.easeOut),
      ),
    );

    logoUpwardAnimation = Tween<AlignmentGeometry>(
      begin: Alignment.center,
      end: Alignment(0.0, -0.4),
    ).animate(
      CurvedAnimation(
        parent: logoUpwardAnimationController,
        curve: Curves.easeOut,
      ),
    );

    initialAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        dev.log("First Animation Completed");
        showRectangle.value = true;

        logoAlignmentAnimation = logoUpwardAnimation;

        logoUpwardAnimationController.forward();
      }
    });

    logoUpwardAnimationController.addStatusListener((status) {
      if (status.isCompleted) {
        dev.log("Second Animation Completed, now the text will come.");

        // Start text animation after logo moves up
        animatedTextOpacityAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animatedTextAnimationController,
            curve: Curves.easeIn,
          ),
        );
        animatedTextAnimationController.forward();
      }
    });

    initialAnimationController.forward();
  }

  @override
  void onClose() {
    initialAnimationController.dispose();
    finalAnimationController.dispose();
    logoUpwardAnimationController.dispose();
    animatedTextAnimationController.dispose();
    super.onClose();
  }

  double calculateFinalDiameter(Size screenSize) {
    return sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2)) * 1.1;
  }

  void navigateToHome() {
    Future.delayed(animatedTextAnimationController.duration!, () {
      Get.offAllNamed(AppRoutes.dashboard);
    });
  }
}
