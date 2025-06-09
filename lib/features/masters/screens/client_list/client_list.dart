import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/screens/client_list/responsive_screens/desktop.dart';
import 'package:doc_sync/features/masters/screens/client_list/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: ClientListMobileScreen(),
      desktop: ClientListDesktopScreen(),
    );
  }
} 