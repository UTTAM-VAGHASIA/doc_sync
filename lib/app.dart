import 'package:doc_sync/routes/app_route_pages.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Doc Sync",
      themeMode: ThemeMode.light,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      getPages: AppRoutePages.pages,
      initialRoute: AppRoutes.login,
      unknownRoute: GetPage(
        name: "/page-not-found",
        page:
            () =>
                Scaffold(body: Center(child: Text('4 0 4  N O T  F O U N D'))),
      ),
    );
  }
}
