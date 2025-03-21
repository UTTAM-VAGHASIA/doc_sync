import 'package:doc_sync/common/widgets/layout/headers/header.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/sidebar.dart';
import 'package:flutter/material.dart';

class DesktopLayout extends StatelessWidget {
  DesktopLayout({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(child: AppSidebar()),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                // HEADER
                AppHeader(),
                // BODY
                body ?? SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
