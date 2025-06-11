// Accountant List Screen

import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/responsive_screens/desktop.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class AccountantListScreen extends StatelessWidget {
  const AccountantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: AccountantListMobileScreen(),
      desktop: AccountantListDesktopScreen(),
    );
  }
} 