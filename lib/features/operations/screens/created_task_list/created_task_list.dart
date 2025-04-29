import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});


    @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: TaskListMobileScreen(),
    );
  }
}