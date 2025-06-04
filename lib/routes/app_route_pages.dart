import 'package:doc_sync/bindings/add_client_binding.dart';
import 'package:doc_sync/bindings/client_list_binding.dart';
import 'package:doc_sync/bindings/new_task_bindings.dart';
import 'package:doc_sync/bindings/created_task_list_binding.dart';
import 'package:doc_sync/common/widgets/layout/templates/placeholder_screen.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/dashboard.dart';
import 'package:doc_sync/features/authentication/screens/forgot_password/forgot_password.dart';
import 'package:doc_sync/features/authentication/screens/login/login.dart';
import 'package:doc_sync/features/authentication/screens/reset_password/reset_password.dart';
import 'package:doc_sync/features/authentication/screens/splash_screen/splash_screen.dart';
import 'package:doc_sync/bindings/dashboard_bindings.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/add_client.dart';
import 'package:doc_sync/features/masters/screens/client_list/client_list.dart';
import 'package:doc_sync/features/operations/screens/new_task/new_task.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/created_task_list.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/admin_verification.dart';
import 'package:doc_sync/bindings/admin_verification_binding.dart';

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
    GetPage(
      name: AppRoutes.adminVerfication,
      page: () => AdminVerificationScreen(),
      binding: AdminVerificationBinding(),
    ),
    // Add placeholder screens for unimplemented routes
    GetPage(
      name: AppRoutes.taskHistory,
      page: () => PlaceholderScreen(title: 'Task History'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.futureTasks,
      page: () => PlaceholderScreen(title: 'Future Tasks'),
    ),
    GetPage(
      name: AppRoutes.addClient,
      page: () => AddClientScreen(),
      binding: AddClientBindings(),
    ),
    GetPage(
      name: AppRoutes.client,
      page: () => ClientListScreen(),
      binding: ClientListBindings(),
    ),
    GetPage(
      name: AppRoutes.staff,
      page: () => PlaceholderScreen(title: 'Staff Management'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.group,
      page: () => PlaceholderScreen(title: 'Group Management'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.taskMaster,
      page: () => PlaceholderScreen(title: 'Task Master'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.subTask,
      page: () => PlaceholderScreen(title: 'Sub-Task Management'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.accountant,
      page: () => PlaceholderScreen(title: 'Accountant'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.financialYear,
      page: () => PlaceholderScreen(title: 'Financial Year'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.userLog,
      page: () => PlaceholderScreen(title: 'User Logs'),
      middlewares: [RouteMiddleWare()],
    ),
    GetPage(
      name: AppRoutes.onDemandReport,
      page: () => PlaceholderScreen(title: 'On-Demand Reports'),
      middlewares: [RouteMiddleWare()],
    ),
  ];
}
