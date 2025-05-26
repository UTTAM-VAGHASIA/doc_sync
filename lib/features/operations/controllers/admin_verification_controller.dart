import 'dart:convert';

import 'package:doc_sync/features/operations/models/admin_verification_task_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AdminVerificationController extends GetxController {
  static AdminVerificationController get instance =>
      Get.find<AdminVerificationController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  final RxList<AdminVerificationTask> tasks = <AdminVerificationTask>[].obs;
  final RxList<AdminVerificationTask> filteredTasks =
      <AdminVerificationTask>[].obs;
  final RxList<AdminVerificationTask> paginatedTasks =
      <AdminVerificationTask>[].obs;

  final RxBool isLoading = false.obs;

  final Rx<DateTime?> filterTaskDate = Rx<DateTime?>(null);

  final RxString filterTaskDateStr = "".obs;

  // Search and filter
  final RxString searchQuery = ''.obs;
  final RxSet<String> activeFilters = {'all'}.obs;

  // Sorting
  final RxString sortBy = 'date'.obs;
  final RxBool sortAscending = true.obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 10;
  final RxInt totalPages = 1.obs;

  // Task status counts
  final RxInt allottedCount = 0.obs;
  final RxInt completedCount = 0.obs;
  final RxInt awaitingCount = 0.obs;
  final RxInt reallottedCount = 0.obs;
  int get totalTasksCount => filteredTasks.length;

  // Add getters for status counts
  int get totalAllotted => allottedCount.value;
  int get totalCompleted => completedCount.value;
  int get totalAwaiting => awaitingCount.value;
  int get totalReallotted => reallottedCount.value;

  // Task priority counts
  final RxInt highPriorityCount = 0.obs;
  final RxInt mediumPriorityCount = 0.obs;
  final RxInt lowPriorityCount = 0.obs;

  // Add pagination methods
  void nextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      print("Moving to next page: ${currentPage.value}");
    }
  }

  void previousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
      print("Moving to previous page: ${currentPage.value}");
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchTasks();

    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFilters());
    ever(activeFilters, (_) => _applyFilters());
    ever(sortBy, (_) => _applyFilters());
    ever(sortAscending, (_) => _applyFilters());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      tasks.clear();
      filteredTasks.clear();
      paginatedTasks.clear();

      final requestData = {
        'data': jsonEncode({"filter_task_date": filterTaskDateStr.value}),
      };

      print("Request data: $requestData");

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchTasks);
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest(
        "get_admin_verification",
        method: "POST",
        fields: requestData,
      );

      print("Raw response from API:\n${jsonEncode(data)}");

      if (data['success'] == true) {
        final tasksListData = data['data'];

        if (tasksListData == null || tasksListData.isEmpty) {
          print("No tasks received.");
          tasks.value = [];
          filteredTasks.value = [];
          paginatedTasks.value = [];
          return;
        }

        final tasksList =
            tasksListData
                .map<AdminVerificationTask>(
                  (json) => AdminVerificationTask.fromJson(
                    json as Map<String, dynamic>,
                  ),
                )
                .toList();

        tasks.value = tasksList;
        _updateTaskCounts();
        _applyFilters();
        print("✅ Fetched ${tasks.length} tasks");
      } else {
        print("❌ Response error: ${data['message']}");
        AppLoaders.errorSnackBar(
          title: "Admin Verification Error",
          message: data['message'] ?? "Failed to load admin verification data",
        );
      }
    } catch (e, stack) {
      print("❗ Exception caught during fetchTasks: $e");
      print("Stack trace: $stack");

      AppLoaders.errorSnackBar(
        title: "Admin Verification Error",
        message: "Error loading tasks: ${e.toString()}",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateTaskCounts() {
    allottedCount.value =
        tasks
            .where((task) => task.taskStatus == AdminTaskStatus.allotted)
            .length;
    completedCount.value =
        tasks
            .where((task) => task.taskStatus == AdminTaskStatus.completed)
            .length;
    awaitingCount.value =
        tasks
            .where((task) => task.taskStatus == AdminTaskStatus.awaiting)
            .length;
    reallottedCount.value =
        tasks
            .where((task) => task.taskStatus == AdminTaskStatus.reallotted)
            .length;

    // Calculate priority counts
    highPriorityCount.value =
        tasks
            .where((task) => task.taskPriority == AdminTaskPriority.high)
            .length;
    mediumPriorityCount.value =
        tasks
            .where((task) => task.taskPriority == AdminTaskPriority.medium)
            .length;
    lowPriorityCount.value =
        tasks
            .where((task) => task.taskPriority == AdminTaskPriority.low)
            .length;

    print(
      "Task counts updated: allotted=${allottedCount.value}, completed=${completedCount.value}",
    );
  }

  void updateSearch(String query) {
    print("Search query updated to: $query");
    searchQuery.value = query;
    _applyFilters();
  }

  void updateFilter(String filter) {
    print("Filter updated to: $filter");
    if (filter == 'all') {
      activeFilters.clear();
      activeFilters.add('all');
    } else {
      activeFilters.remove('all');
      if (activeFilters.contains(filter)) {
        activeFilters.remove(filter);
        if (activeFilters.isEmpty) {
          activeFilters.add('all');
        }
      } else {
        activeFilters.add(filter);
      }
    }
    _applyFilters();
  }

  void updateSort(String field) {
    if (sortBy.value == field) {
      sortAscending.value = !sortAscending.value;
      print(
        "Sort direction updated to: ${sortAscending.value ? 'ascending' : 'descending'}",
      );
    } else {
      sortBy.value = field;
      sortAscending.value = true;
      print("Sort updated to: $field, direction: ascending");
    }
    _applyFilters();
  }

  void setAllotedDate(DateTime? date) {
    filterTaskDate.value = date;
    filterTaskDateStr.value =
        date != null ? DateFormat("yyyy-MM-dd").format(date) : "";
    fetchTasks();
  }

  Future<void> clearDate() async {
    filterTaskDate.value = null;
    filterTaskDateStr.value = "";
    fetchTasks();
  }

  void _applyFilters() {
    List<AdminVerificationTask> filteredTasksList = tasks.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filteredTasksList =
          filteredTasksList.where((task) {
            return task.taskName.toLowerCase().contains(query) ||
                task.clientName.toLowerCase().contains(query) ||
                task.fileNo.toLowerCase().contains(query) ||
                task.subTaskName.toLowerCase().contains(query);
          }).toList();
    }

    // Apply status filters
    if (!activeFilters.contains('all')) {
      filteredTasksList =
          filteredTasksList.where((task) {
            final status = task.taskStatus;
            return activeFilters.contains(status.toString().split('.').last);
          }).toList();
    }

    // Apply sorting
    filteredTasksList.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'date':
          comparison = a.allottedDate.compareTo(b.allottedDate);
          break;
        case 'priority':
          comparison = a.taskPriority.index.compareTo(b.taskPriority.index);
          break;
        case 'status':
          comparison = a.taskStatus.index.compareTo(b.taskStatus.index);
          break;
        default:
          comparison = 0;
      }
      return sortAscending.value ? comparison : -comparison;
    });

    // Update pagination
    totalPages.value = (filteredTasksList.length / itemsPerPage).ceil();
    currentPage.value = 1;
    filteredTasks.assignAll(filteredTasksList);
    _paginate();
  }

  void _paginate() {
    final start = (currentPage.value - 1) * itemsPerPage;
    final end = start + itemsPerPage;

    if (start >= filteredTasks.length) {
      paginatedTasks.clear();
      return;
    }

    paginatedTasks.assignAll(
      filteredTasks.sublist(
        start,
        end > filteredTasks.length ? filteredTasks.length : end,
      ),
    );

    print("Paginated tasks: ${paginatedTasks.length} items");
  }

  List<AdminVerificationTask> get paginatedTasksList => paginatedTasks;
}
