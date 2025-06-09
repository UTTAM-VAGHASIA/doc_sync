import 'package:doc_sync/features/masters/screens/task_master/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class TaskMasterDesktopScreen extends StatelessWidget {
  const TaskMasterDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, just use the mobile version - can be customized later
    // This is just a placeholder to ensure our modular architecture supports multiple screen sizes
    return const TaskMasterMobileScreen();

    // When implementing a desktop-specific layout in the future,
    // you can leverage the same modular widgets created for the mobile layout
    // but arrange them differently to take advantage of the larger screen size
  }
} 