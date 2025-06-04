import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class AddClientScreen extends StatelessWidget {
  const AddClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: AddClientMobileScreen(),
    );
  }
}
