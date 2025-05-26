import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/responsive_screens/desktop.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class AdminVerificationScreen extends StatelessWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: AdminVerificationMobileScreen(),
      desktop: AdminVerificationDesktopScreen(),
    );
  }
}
