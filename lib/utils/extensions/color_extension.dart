import 'package:flutter/material.dart';

/// Extension on Color to provide additional functionality
extension ColorExtension on Color {
  /// Creates a copy of this color with the given alpha value.
  /// This is a custom method to match the existing codebase usage of withValues.
  Color withValues({double? alpha}) {
    return withOpacity(alpha ?? opacity);
  }
}
