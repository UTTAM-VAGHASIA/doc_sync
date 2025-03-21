import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class AppResponsiveWidget extends StatelessWidget {
  const AppResponsiveWidget({
    super.key,
    required this.desktop,
    required this.tablet,
    required this.mobile,
  });

  // Widget for Desktop Layout
  final Widget desktop;

  // Widget for Tablet Layout
  final Widget tablet;

  // Widget for Mobile Layout
  final Widget mobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth >= AppSizes.desktopScreenSize) {
          return desktop;
        } else if (constraints.maxWidth < AppSizes.desktopScreenSize &&
            constraints.maxWidth >= AppSizes.tabletScreenSize) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
