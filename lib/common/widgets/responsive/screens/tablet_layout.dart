import 'package:doc_sync/common/widgets/layout/headers/header.dart';
import 'package:doc_sync/common/widgets/layout/sidebars/sidebar.dart';
import 'package:flutter/material.dart';

class TabletLayout extends StatelessWidget {
  TabletLayout({super.key, this.body});

  final Widget? body;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: AppSidebar(),
      drawerEdgeDragWidth: 100,
      appBar: AppHeader(scaffoldKey: scaffoldKey),
      body: body ?? const SizedBox(),
    );
  }
}
