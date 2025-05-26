import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/features/operations/screens/new_task/responsive_screens/desktop.dart';
import 'package:doc_sync/features/operations/screens/new_task/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';

class NewTaskScreen extends StatelessWidget {
  const NewTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: NewTaskMobileScreen(),
      desktop: NewTaskDesktopScreen(),
    );
  }
}
