import 'dart:convert';

import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/authentication/models/dashboard_table_item_model.dart';
import 'package:doc_sync/features/authentication/models/user_model.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  static DashboardController get instance => Get.find<DashboardController>();

  final userController = UserController.instance;
  
  // Add a flag to track if the data has already been fetched
  final RxBool dataAlreadyFetched = false.obs;

  final RxInt currentCarouselIndex = 0.obs;

  final RxInt todayCreated = 0.obs;
  final RxInt todayAllotedMe = 0.obs;
  final RxInt todayCompleted = 0.obs;
  final RxInt todayPending = 0.obs;
  final RxInt totalPending = 0.obs;
  final RxInt totalTasks = 0.obs;
  final RxInt runningLate = 0.obs;
  final RxInt totalCompleted = 0.obs;

  final RxList<DashboardTableItemModel> tableItems = <DashboardTableItemModel>[].obs;

  final RxBool isLoading = true.obs;

  // Pagination
  final RxInt currentPage = 0.obs;
  final RxInt itemsPerPage = 10.obs;
  
  // Search and Filter
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'name'.obs;
  final RxBool sortAscending = true.obs;

  // Computed list for filtered and sorted items
  List<DashboardTableItemModel> get filteredItems {
    List<DashboardTableItemModel> filtered = List.from(tableItems);
    
    // Apply search
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) =>
        item.name?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false
      ).toList();
    }
    
    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (sortBy.value) {
        case 'name':
          comparison = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'pending':
          comparison = (a.pending ?? 0).compareTo(b.pending ?? 0);
          break;
        case 'completed':
          comparison = (a.completed ?? 0).compareTo(b.completed ?? 0);
          break;
        default:
          comparison = 0;
      }
      return sortAscending.value ? comparison : -comparison;
    });
    
    return filtered;
  }

  // Get paginated items
  List<DashboardTableItemModel> get paginatedItems {
    final start = currentPage.value * itemsPerPage.value;
    final end = start + itemsPerPage.value;
    final filtered = filteredItems;
    
    if (start >= filtered.length) return [];
    return filtered.sublist(start, end > filtered.length ? filtered.length : end);
  }

  int get totalPages => (filteredItems.length / itemsPerPage.value).ceil();

  void nextPage() {
    if (currentPage.value < totalPages - 1) currentPage.value++;
  }

  void previousPage() {
    if (currentPage.value > 0) currentPage.value--;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 0; // Reset to first page when searching
  }

  void updateSort(String field) {
    if (sortBy.value == field) {
      sortAscending.toggle();
    } else {
      sortBy.value = field;
      sortAscending.value = true;
    }
  }

  // Add this property to track expansion states
  final RxMap<int, bool> expansionStates = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    resetDashboard();
  }

  // Reset the dashboard data to initial state
  void resetDashboard() {
    todayCreated.value = 0;
    todayAllotedMe.value = 0;
    todayCompleted.value = 0;
    todayPending.value = 0;
    totalPending.value = 0;
    totalTasks.value = 0;
    runningLate.value = 0;
    totalCompleted.value = 0;
    tableItems.clear();
    currentPage.value = 0;
    searchQuery.value = '';
    expansionStates.clear();
    dataAlreadyFetched.value = false;
  }

  Future<void> fetchDashboardData() async {
    // Only proceed if the data hasn't been fetched yet or if we're explicitly refreshing
    if (dataAlreadyFetched.value) {
      return;
    }
    
    isLoading.value = true;
    try {
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
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest(
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
        tableItems.addAll(
          tableData.map<DashboardTableItemModel>(
            (item) => DashboardTableItemModel.fromJson(item),
          ),
        );

        // Mark data as fetched
        dataAlreadyFetched.value = true;

        print('Today Created: ${todayCreated.value}');
        print('Today Alloted Me: ${todayAllotedMe.value}');
        print('Today Completed: ${todayCompleted.value}');
        print('Today Pending: ${todayPending.value}');
        print('Total Pending: ${totalPending.value}');
        print('Total Tasks: ${totalTasks.value}');
        print('Running Late: ${runningLate.value}');
        print('Total Completed: ${totalCompleted.value}');
        print('Table Items: ${tableItems.length}');
      } else {
        AppLoaders.errorSnackBar(
          title: "Dashboard Error",
          message: data['message'] ?? "Failed to load dashboard data",
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Dashboard Error",
        message: "Error loading dashboard: ${e.toString()}",
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Add a method for explicitly refreshing the data
  Future<void> refreshDashboardData() async {
    // Reset the flag to allow a fresh fetch
    dataAlreadyFetched.value = false;
    // Call the fetch method
    await fetchDashboardData();
  }
}
