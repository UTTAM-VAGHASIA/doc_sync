import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/authentication/screens/reset_password/responsive_screens/desktop_tablet.dart';
import 'package:doc_sync/features/authentication/screens/reset_password/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteLayoutTemplate(
      useLayout: false,
      desktop: DesktopTabletResetPasswordScreen(),
      mobile: MobileResetPasswordScreen(),
    );
  }
}
