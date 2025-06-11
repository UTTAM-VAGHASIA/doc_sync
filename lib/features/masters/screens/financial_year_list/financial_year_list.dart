// Financial Year List Screen

import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/responsive_screens/desktop.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class FinancialYearListScreen extends StatelessWidget {
  const FinancialYearListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: FinancialYearListMobileScreen(),
      desktop: FinancialYearListDesktopScreen(),
    );
  }
} 