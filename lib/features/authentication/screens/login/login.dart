import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/authentication/screens/login/responsive_screens/desktop_tablet.dart';
import 'package:doc_sync/features/authentication/screens/login/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteLayoutTemplate(
      useLayout: false,
      desktop: DesktopTabletLoginScreen(),
      mobile: MobileLoginScreen(),
    );
  }
}
