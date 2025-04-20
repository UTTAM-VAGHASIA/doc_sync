// lib/loading/widgets/final_content_view.dart
import 'package:flutter/material.dart';
import 'animated_loading_text.dart'; // Import the animated text

class FinalContentView extends StatelessWidget {
  const FinalContentView({super.key});

  @override
  Widget build(BuildContext context) {
    // You can add more widgets here if needed (e.g., buttons)
    // using Column, Stack, etc.
    return AnimatedLoadingText();
  }
}