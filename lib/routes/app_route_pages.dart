import 'package:doc_sync/features/authentication/screens/dashboard/dashboard.dart';
import 'package:doc_sync/features/authentication/screens/forgot_password/forgot_password.dart';
import 'package:doc_sync/features/authentication/screens/login/login.dart';
import 'package:doc_sync/features/authentication/screens/reset_password/reset_password.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/routes/routes_middleware.dart';
import 'package:get/get.dart';

class AppRoutePages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),

    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),

    GetPage(name: AppRoutes.resetPassword, page: () => ResetPasswordScreen()),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      middlewares: [RouteMiddleWare()],
    ),
  ];
}
