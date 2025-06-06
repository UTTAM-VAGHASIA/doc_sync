import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/operations/screens/task_history/responsive_screens/desktop.dart';
import 'package:doc_sync/features/operations/screens/task_history/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: TaskHistoryMobileScreen(),
      desktop: TaskHistoryDesktopScreen(),
    );
  }
} 