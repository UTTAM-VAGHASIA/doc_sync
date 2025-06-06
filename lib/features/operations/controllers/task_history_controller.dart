import 'dart:convert';

import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/operations/models/task_history_model.dart';
import 'package:doc_sync/utils/constants/enums.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TaskHistoryController extends GetxController {
  static TaskHistoryController get instance =>
      Get.find<TaskHistoryController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  final RxList<TaskHistoryTask> tasks = <TaskHistoryTask>[].obs;
  final RxList<TaskHistoryTask> filteredTasks =
      <TaskHistoryTask>[].obs;
  final RxList<TaskHistoryTask> paginatedTasks =
      <TaskHistoryTask>[].obs;

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
  int _itemsPerPage = 10;
  final RxInt totalPages = 1.obs;

  // Getter and setter for itemsPerPage
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFilters();
  }

  // Task status counts
  final RxInt allottedCount = 0.obs;
  final RxInt completedCount = 0.obs;
  final RxInt clientAwaitingCount = 0.obs;
  final RxInt ReAllottedCount = 0.obs;
  final RxInt pendingCount = 0.obs;
  int get totalTasksCount => filteredTasks.length;

  // Add getters for status counts
  int get totalAllotted => allottedCount.value;
  int get totalCompleted => completedCount.value;
  int get totalClientWaiting => clientAwaitingCount.value;
  int get totalReallotted => ReAllottedCount.value;

  // Task priority counts
  final RxInt highPriorityCount = 0.obs;
  final RxInt mediumPriorityCount = 0.obs;
  final RxInt lowPriorityCount = 0.obs;

  // Add getters for priority counts
  int get totalHighPriority => highPriorityCount.value;
  int get totalMediumPriority => mediumPriorityCount.value;
  int get totalLowPriority => lowPriorityCount.value;

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

  // Add these methods for pagination controls
  void goToFirstPage() {
    currentPage.value = 1;
  }

  void goToPreviousPage() {
    if (currentPage.value > 1) {
      currentPage.value--;
    }
  }

  void goToNextPage() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
    }
  }

  void goToLastPage() {
    currentPage.value = totalPages.value;
  }

  // Method to skip multiple pages backward
  void skipPagesBackward() {
    int skipSize = _calculateSkipSize();
    int targetPage = (currentPage.value - skipSize).clamp(1, totalPages.value);
    currentPage.value = targetPage;
    print("Skipping $skipSize pages backward to page: $targetPage");
  }
  
  // Method to skip multiple pages forward
  void skipPagesForward() {
    int skipSize = _calculateSkipSize();
    int targetPage = (currentPage.value + skipSize).clamp(1, totalPages.value);
    currentPage.value = targetPage;
    print("Skipping $skipSize pages forward to page: $targetPage");
  }
  
  // Calculate how many pages to skip based on total page count
  int _calculateSkipSize() {
    if (totalPages.value > 300) {
      return 100; // Skip 100 pages if more than 300 pages
    } else if (totalPages.value > 100) {
      return 50; // Skip 50 pages if between 100 and 300 pages
    } else if (totalPages.value > 50) {
      return 10; // Skip 10 pages if between 50 and 100 pages
    } else {
      return 5; // Skip 5 pages for smaller page counts
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

      // Build request data based on API requirements
      final requestData = {
        'data': jsonEncode({
          "user_type": getRole(),
          "user_id": UserController.instance.user.value.id.toString(),  // This would typically come from user authentication
          // Include date filter only if it's set
          if (filterTaskDateStr.value.isNotEmpty) "filter_task_date": filterTaskDateStr.value
        }),
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
        "get_filtered_tasks", 
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
                .map<TaskHistoryTask>(
                  (json) => TaskHistoryTask.fromJson(
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
          title: "Task History Error",
          message: data['message'] ?? "Failed to load task history data",
        );
      }
    } catch (e, stack) {
      print("❗ Exception caught during fetchTasks: $e");
      print("Stack trace: $stack");

      AppLoaders.errorSnackBar(
        title: "Task History Error",
        message: "Error loading tasks: ${e.toString()}",
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _updateTaskCounts() {
    // Status counts
    allottedCount.value =
        tasks.where((task) => task.taskStatus == TaskHistoryStatus.allotted).length;
    completedCount.value =
        tasks.where((task) => task.taskStatus == TaskHistoryStatus.completed).length;
    clientAwaitingCount.value =
        tasks.where((task) => task.taskStatus == TaskHistoryStatus.client_waiting).length;
    ReAllottedCount.value =
        tasks.where((task) => task.taskStatus == TaskHistoryStatus.re_alloted).length;
    pendingCount.value =
        tasks.where((task) => task.taskStatus == TaskHistoryStatus.pending).length;

    // Priority counts
    highPriorityCount.value =
        tasks.where((task) => task.taskPriority == TaskHistoryPriority.high).length;
    mediumPriorityCount.value =
        tasks.where((task) => task.taskPriority == TaskHistoryPriority.medium).length;
    lowPriorityCount.value =
        tasks.where((task) => task.taskPriority == TaskHistoryPriority.low).length;

    print(
      "Task counts updated: allotted=${allottedCount.value}, completed=${completedCount.value}, high=${highPriorityCount.value}, medium=${mediumPriorityCount.value}, low=${lowPriorityCount.value}",
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
    currentPage.value = 1; // Reset to first page when filter changes
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
    List<TaskHistoryTask> filteredTasksList = tasks.toList();

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filteredTasksList = filteredTasksList.where((task) {
        return task.taskName.toLowerCase().contains(query) ||
            task.clientName.toLowerCase().contains(query) ||
            task.fileNo.toLowerCase().contains(query) ||
            task.subTaskName.toLowerCase().contains(query);
      }).toList();
    }

    // Apply status and priority filters
    if (!activeFilters.contains('all')) {
      filteredTasksList = filteredTasksList.where((task) {
        return activeFilters.any((filter) {
          switch (filter) {
            case 'allotted':
              return task.taskStatus == TaskHistoryStatus.allotted;
            case 'completed':
              return task.taskStatus == TaskHistoryStatus.completed;
            case 'client_waiting':
              return task.taskStatus == TaskHistoryStatus.client_waiting;
            case 're_alloted':
              return task.taskStatus == TaskHistoryStatus.re_alloted;
            case 'pending':
              return task.taskStatus == TaskHistoryStatus.pending;
            case 'high':
              return task.taskPriority == TaskHistoryPriority.high;
            case 'medium':
              return task.taskPriority == TaskHistoryPriority.medium;
            case 'low':
              return task.taskPriority == TaskHistoryPriority.low;
            default:
              return false;
          }
        });
      }).toList();
    }

    // Apply sorting
    filteredTasksList.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'date':
          comparison = a.allottedDate.compareTo(b.allottedDate);
          break;
        case 'name':
          comparison = a.taskName.compareTo(b.taskName);
          break;
        case 'client':
          comparison = a.clientName.compareTo(b.clientName);
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
    if (totalPages.value == 0) totalPages.value = 1;
    if (currentPage.value > totalPages.value) currentPage.value = totalPages.value;
    filteredTasks.assignAll(filteredTasksList);
    _paginate();
  }

  void _paginate() {
    final start = (currentPage.value - 1) * itemsPerPage;
    
    if (filteredTasks.isEmpty) {
      paginatedTasks.clear();
      print("No tasks to paginate");
      return;
    }
    
    // Make sure we don't go out of bounds
    final end = (start + itemsPerPage <= filteredTasks.length) 
        ? start + itemsPerPage 
        : filteredTasks.length;
        
    if (start >= filteredTasks.length) {
      // This can happen if we were on the last page and then filter reduced results
      currentPage.value = 1;
      _paginate();
      return;
    }
    
    paginatedTasks.assignAll(filteredTasks.sublist(start, end));
    print("Paginated tasks updated: showing ${paginatedTasks.length} tasks from index $start to ${end-1}");
  }

  List<TaskHistoryTask> get paginatedTasksList => paginatedTasks;

  // Public method to refresh filtering and pagination
  void refreshFiltersAndPagination() {
    _applyFilters();
  }
  
  String getRole() {
    if(UserController.instance.user.value.type == AppRole.admin) {
      return "admin";
    } else if(UserController.instance.user.value.type == AppRole.superadmin) {
      return "superadmin";
    } else {
      return "staff";
    }
  }
} 