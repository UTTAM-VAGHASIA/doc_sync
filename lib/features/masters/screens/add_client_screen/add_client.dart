import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/responsive_screens/desktop.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddClientScreen extends StatelessWidget {
  const AddClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure the controller is available
    if (!Get.isRegistered<AddClientController>()) {
      Get.put(AddClientController());
    }

    return const SiteLayoutTemplate(
      mobile: AddClientMobileScreen(),
      desktop: AddClientDesktopScreen(),
    );
  }
}
