import 'package:doc_sync/common/widgets/responsive/responsive_design.dart';
import 'package:doc_sync/common/widgets/responsive/screens/desktop_layout.dart';
import 'package:doc_sync/common/widgets/responsive/screens/mobile_layout.dart';
import 'package:doc_sync/common/widgets/responsive/screens/tablet_layout.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class SiteLayoutTemplate extends StatelessWidget {
  const SiteLayoutTemplate({
    super.key,
    this.desktop,
    this.tablet,
    this.mobile,
    this.useLayout = true,
  });

  // Widget for Desktop Layout
  final Widget? desktop;
  // Widget for Tablet Layout
  final Widget? tablet;
  // Widget for Mobile Layout
  final Widget? mobile;
  //flag to determine to use the responsive layout
  final bool useLayout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: AppResponsiveWidget(
        desktop:
            useLayout ? DesktopLayout(body: desktop) : desktop ?? Container(),
        tablet:
            useLayout
                ? TabletLayout(body: tablet ?? desktop)
                : tablet ?? desktop ?? Container(),
        mobile:
            useLayout
                ? MobileLayout(body: mobile ?? desktop)
                : mobile ?? desktop ?? Container(),
      ),
    );
  }
}
