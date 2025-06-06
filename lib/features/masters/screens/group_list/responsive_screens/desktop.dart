import 'package:doc_sync/features/masters/screens/group_list/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class GroupListDesktopScreen extends StatelessWidget {
  const GroupListDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, just use the mobile version - can be customized later
    // This is just a placeholder to ensure our modular architecture supports multiple screen sizes
    return const GroupListMobileScreen();

    // When implementing a desktop-specific layout in the future,
    // you can leverage the same modular widgets created for the mobile layout
    // but arrange them differently to take advantage of the larger screen size
  }
} 