import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/authentication/screens/forgot_password/responsive_screens/desktop_tablet.dart';
import 'package:doc_sync/features/authentication/screens/forgot_password/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteLayoutTemplate(
      useLayout: false,
      desktop: DesktopTabletForgotPasswordScreen(),
      mobile: MobileForgotPasswordScreen(),
    );
  }
}
