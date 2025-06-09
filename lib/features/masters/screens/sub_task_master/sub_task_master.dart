
import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/responsive_screens/desktop.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class SubTaskMasterScreen extends StatelessWidget {
  const SubTaskMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: SubTaskMasterMobileScreen(),
      desktop: SubTaskMasterDesktopScreen(),
    );
  }
} 