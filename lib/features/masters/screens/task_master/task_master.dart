import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/screens/task_master/responsive_screens/desktop.dart';
import 'package:doc_sync/features/masters/screens/task_master/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class TaskMasterScreen extends StatelessWidget {
  const TaskMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: TaskMasterMobileScreen(),
      desktop: TaskMasterDesktopScreen(),
    );
  }
} 