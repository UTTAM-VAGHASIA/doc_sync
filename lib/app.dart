import 'package:device_preview/device_preview.dart';
import 'package:doc_sync/bindings/general_bindings.dart';
import 'package:doc_sync/routes/app_route_pages.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: "Doc Sync",
      themeMode: ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      getPages: AppRoutePages.pages,
      initialBinding: GeneralBindings(),
      initialRoute: AppRoutes.splash,
      unknownRoute: GetPage(
        name: "/page-not-found",
        page:
            () =>
                Scaffold(body: Center(child: Text('4 0 4  N O T  F O U N D'))),
      ),
    );
  }
}
