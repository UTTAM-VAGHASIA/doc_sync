// Sub Task Master Desktop Screen
// TODO: Implement Sub Task Master Desktop screen 

import 'package:doc_sync/features/masters/screens/sub_task_master/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class SubTaskMasterDesktopScreen extends StatelessWidget {
  const SubTaskMasterDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, just use the mobile version - can be customized later
    // This is just a placeholder to ensure our modular architecture supports multiple screen sizes
    return const SubTaskMasterMobileScreen();

    // When implementing a desktop-specific layout in the future,
    // you can leverage the same modular widgets created for the mobile layout
    // but arrange them differently to take advantage of the larger screen size
  }
} 