import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/responsive_screens/desktop.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/responsive_screens/mobile.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/responsive_screens/tablet.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      desktop: DashboardDesktopScreen(),
      tablet: DashboardTabletScreen(),
      mobile: DashboardMobileScreen(),
    );
  }
}
