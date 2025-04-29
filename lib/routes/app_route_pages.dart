import 'package:doc_sync/bindings/new_task_bindings.dart';
import 'package:doc_sync/bindings/created_task_list_binding.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/dashboard.dart';
import 'package:doc_sync/features/authentication/screens/forgot_password/forgot_password.dart';
import 'package:doc_sync/features/authentication/screens/login/login.dart';
import 'package:doc_sync/features/authentication/screens/reset_password/reset_password.dart';
import 'package:doc_sync/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:doc_sync/bindings/dashboard_bindings.dart';
import 'package:doc_sync/features/operations/screens/new_task/new_task.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/created_task_list.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/routes/routes_middleware.dart';
import 'package:get/get.dart';

class AppRoutePages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),

    GetPage(name: AppRoutes.splash, page: () => SplashScreen()),

    GetPage(name: AppRoutes.forgotPassword, page: () => ForgotPasswordScreen()),

    GetPage(name: AppRoutes.resetPassword, page: () => ResetPasswordScreen()),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardScreen(),
      binding: DashboardBindings(),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.addNewTask,
      page: () => NewTaskScreen(),
      binding: NewTaskBindings(),
    ),
    GetPage(
      name: AppRoutes.tasks,
      page: () => TaskListScreen(),
      binding: TaskListBindings(),
    ),
  ];
}
