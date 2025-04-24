import 'dart:convert';

import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/authentication/models/dashboard_table_item_model.dart';
import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  static DashboardController get instance => Get.find();

  final userController = UserController.instance;

  final RxInt currentCarouselIndex = 0.obs;

  final RxInt todayCreated = 0.obs;
  final RxInt todayAllotedMe = 0.obs;
  final RxInt todayCompleted = 0.obs;
  final RxInt todayPending = 0.obs;
  final RxInt totalPending = 0.obs;
  final RxInt totalTasks = 0.obs;
  final RxInt runningLate = 0.obs;
  final RxInt totalCompleted = 0.obs;

  final List<DashboardTableItemModel> tableItems = [];

  @override
  void onInit() {
    fetchDashboardData();
    super.onInit();
  }

  Future<void> fetchDashboardData() async {
    User user = await userController.getUserDetails();

    final requestData = {
      'data': jsonEncode({
        "user_id": user.id,
        "user_type": switch (user.type) {
          AppRole.superadmin => "admin",
          AppRole.admin => "admin",
          AppRole.staff => "staff",
          _ => "",
        },
      }),
    };

    final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchDashboardData);
        return;
      }

    print(requestData);

    final data = await AppHttpHelper.sendMultipartRequest(
      "dashboard",
      method: "POST",
      fields: requestData,
    );

    if (data['success']) {
      final dashboardData = data['data'];

      todayCreated.value = dashboardData['today_created'];
      todayAllotedMe.value = 0;
      todayCompleted.value = dashboardData['today_completed'];
      todayPending.value = dashboardData['today_pending'];
      totalPending.value = dashboardData['total_pending'];
      totalTasks.value = dashboardData['total_tasks'];
      runningLate.value = dashboardData['running_late'];

      final tableData = dashboardData['staff_status_summary'];

      tableItems.clear();

      for (var item in tableData) {
        tableItems.add(DashboardTableItemModel.fromJson(item));
      }

      print('Today Created: ${todayCreated.value}');
      print('Today Alloted Me: ${todayAllotedMe.value}');
      print('Today Completed: ${todayCompleted.value}');
      print('Today Pending: ${todayPending.value}');
      print('Total Pending: ${totalPending.value}');
      print('Total Tasks: ${totalTasks.value}');
      print('Running Late: ${runningLate.value}');
      print('Total Completed: ${totalCompleted.value}');
      print('Table Items: ${tableItems.length}');
    }
    //
  }
}
