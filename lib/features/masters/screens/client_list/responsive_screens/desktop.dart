import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientListDesktopScreen extends StatelessWidget {
  const ClientListDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final clientListController = Get.put(ClientListController());
    
    return Center(
      child: Text(
        'Desktop version of client list will be implemented soon',
        style: Theme.of(context).textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
} 