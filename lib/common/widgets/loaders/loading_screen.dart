// lib/loading/loading_screen.dart
import 'dart:math';
import 'dart:ui';

import 'package:doc_sync/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/animated_visual_element.dart'; // Import the visual element
import 'widgets/final_content_view.dart'; // Import the final content view

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _alignmentAnimation;

  // --- Configuration ---
  final Duration _animationDuration = const Duration(milliseconds: 1400);
  final double _initialCircleDiameter = 40.0;
  final double _initialLogoDiameter = 20.0;
  final Color _splashColor = const Color(0xFF2A5781);
  final String _logoAssetPath = 'assets/logos/app-logo.png'; // Centralized path

  // Timing Intervals
  final double _dropPhaseEnd = 0.35;
  final double _expandPhaseEnd = 0.9;

  // State flag
  bool _showRectangle = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _alignmentAnimation = Tween<AlignmentGeometry>(
      begin: const Alignment(0.0, -1.5),
      end: Alignment.center,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, _dropPhaseEnd, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _showRectangle = true; // Trigger final state
          });
        }
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateFinalDiameter(Size screenSize) {
    return sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2)) * 1.1;
  }

  // --- Navigation placeholder ---
  void _navigateToHome() {
    Get.offAllNamed(AppRoutes.loading);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double finalDiameter = _calculateFinalDiameter(screenSize);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // --- 1. Calculate Animation Progress ---
          final double expansionProgress = Interval(
            _dropPhaseEnd,
            _expandPhaseEnd,
            curve: Curves.easeInOut,
          ).transform(_controller.value).clamp(0.0, 1.0);

          // --- 2. Calculate Current Animated Values ---
          final double currentAnimatingDiameter =
              lerpDouble(
                _initialCircleDiameter,
                finalDiameter,
                expansionProgress,
              )!;

          final double currentLogoDiameter =
              lerpDouble(
                _initialLogoDiameter,
                // Logo grows proportionally, capped potentially by initial size relation
                max(_initialLogoDiameter, currentAnimatingDiameter * 0.2),
                expansionProgress,
              )!;

          // --- 3. Determine Display Properties ---
          double displayWidth;
          double displayHeight;
          BoxShape displayShape;
          BorderRadius? displayBorderRadius;
          bool needsOverflow = false;

          if (_showRectangle) {
            // Final State: Full Screen Rectangle
            displayWidth = screenSize.width;
            displayHeight = screenSize.height;
            displayShape = BoxShape.rectangle;
            displayBorderRadius = BorderRadius.zero;
            needsOverflow = false;
          } else {
            // Animation State: Dropping or Expanding Circle
            displayWidth = currentAnimatingDiameter;
            displayHeight = currentAnimatingDiameter;
            displayShape = BoxShape.circle;
            displayBorderRadius = null;
            needsOverflow = _controller.value >= _dropPhaseEnd;
          }

          // --- 4. Build the Core Animated Visual Element (using the dedicated widget) ---
          Widget visualElement = AnimatedVisualElement(
            width: displayWidth,
            height: displayHeight,
            color: _splashColor,
            shape: displayShape,
            borderRadius: displayBorderRadius,
            logoDiameter: currentLogoDiameter,
            logoAssetPath: _logoAssetPath,
            isRectangle: _showRectangle,
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
              Align(
                alignment: _alignmentAnimation.value,
                child:
                    // Layer 1: The Animated Element (Circle/Rectangle), positioned
                    visualElement,
              ),

              // // Layer 2: Content shown AFTER animation completes
              if (_showRectangle)
                FinalContentView(), // Display the final content widget
            ],
          );
        },
      ),
    );
  }
}
