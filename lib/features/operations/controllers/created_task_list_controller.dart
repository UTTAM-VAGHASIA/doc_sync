import 'dart:convert';

import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TaskListController extends GetxController {
  
  static TaskListController get instance => Get.find<TaskListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  RxList<Task> tasks = <Task>[].obs;
  RxList<Task> filteredTasks = <Task>[].obs;
  RxList<Task> paginatedTasks = <Task>[].obs;

  RxBool isLoading = false.obs;

  DateTime? allotedDate;

  RxString allotedDateStr = "".obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'date'.obs;
  RxBool sortAscending = false.obs;
  
  // Pagination
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredTasks.isEmpty 
    ? 1 
    : (filteredTasks.length / _itemsPerPage).ceil();
  
  // Task status counts
  RxInt totalAllotted = 0.obs;
  RxInt totalCompleted = 0.obs;
  RxInt totalClientWaiting = 0.obs;
  RxInt totalReallotted = 0.obs;
  RxInt pendingCount = 0.obs;
  int get totalTasksCount => filteredTasks.length;

  // Task priority counts
  RxInt highPriorityCount = 0.obs;
  RxInt mediumPriorityCount = 0.obs;
  RxInt lowPriorityCount = 0.obs;

  // Add these counts for the new filters
  RxInt allottedByMeCount = 0.obs;
  RxInt allottedToMeCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> setAllotedDate(DateTime? date) async {
    allotedDate = date;
    allotedDateStr.value = date != null ? DateFormat("yyyy-MM-dd").format(date) : "";
  }

  Future<void> clearDate() async {
    allotedDate = null;
    allotedDateStr.value = "";
  }

  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;
      tasks.clear();
      filteredTasks.clear();
      paginatedTasks.clear();

      final requestData = {
        'data': jsonEncode({"allotted_date": allotedDateStr.value})
      };

      print(requestData);
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchTasks);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("get_task_details", method: "POST", fields: requestData);

      if (data['success']) {
        final tasksListData = data['data'];
        final tasksList = tasksListData.map<Task>((json) => Task.fromJson(json as Map<String, dynamic>)).toList();
        tasks.value = tasksList;
        _updateTaskCounts();
        _applyFiltersAndSort();
        print("Fetched ${tasks.length} tasks");
      } else {
        AppLoaders.errorSnackBar(
          title: "Created Tasks List Error",
          message: data['message'] ?? "Failed to load dashboard data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Created Tasks List Error",
        message: "Error loading tasks: ${e.toString()}",
      );
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateSearch(String query) {
    print("Search query updated to: $query");
    searchQuery.value = query;
  }
  
  void updateFilter(String filter) {
    print("Filter updated to: $filter");
    if (filter == 'all') {
      activeFilters.clear();
    } else if (activeFilters.contains(filter)) {
      activeFilters.remove(filter);
    } else {
      activeFilters.add(filter);
    }
    currentPage.value = 0; // Reset to first page when filter changes
    _applyFiltersAndSort();
  }
  
  void updateSort(String sort) {
    if (sortBy.value == sort) {
      // If same sort field is selected, toggle direction
      sortAscending.value = !sortAscending.value;
      print("Sort direction updated to: ${sortAscending.value ? 'ascending' : 'descending'}");
    } else {
      // If new sort field is selected, set default direction
      sortBy.value = sort;
      // For date fields, default to descending (newest first)
      sortAscending.value = !(sort == 'date');
      print("Sort updated to: $sort, direction: ${sortAscending.value ? 'ascending' : 'descending'}");
    }
    currentPage.value = 0; // Reset to first page when sort changes
  }
  
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
      print("Moving to next page: ${currentPage.value + 1}");
    }
  }
  
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      print("Moving to previous page: ${currentPage.value + 1}");
    }
  }
  
  // Method to jump to a specific page
  void goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < totalPages) {
      currentPage.value = pageIndex;
      print("Jumping to page: ${pageIndex + 1}");
    }
  }
  
  // Method to skip multiple pages backward
  void skipPagesBackward() {
    int skipSize = _calculateSkipSize();
    int targetPage = (currentPage.value - skipSize).clamp(0, totalPages - 1);
    goToPage(targetPage);
    print("Skipping $skipSize pages backward to page: ${targetPage + 1}");
  }
  
  // Method to skip multiple pages forward
  void skipPagesForward() {
    int skipSize = _calculateSkipSize();
    int targetPage = (currentPage.value + skipSize).clamp(0, totalPages - 1);
    goToPage(targetPage);
    print("Skipping $skipSize pages forward to page: ${targetPage + 1}");
  }
  
  // Calculate how many pages to skip based on total page count
  int _calculateSkipSize() {
    if (totalPages > 300) {
      return 100; // Skip 100 pages if more than 300 pages
    } else if (totalPages > 100) {
      return 50; // Skip 50 pages if between 100 and 300 pages
    } else if (totalPages > 50) {
      return 10; // Skip 10 pages if between 50 and 100 pages
    } else {
      return 5; // Skip 5 pages for smaller page counts
    }
  }
  
  void _updateTaskCounts() {
    // Calculate status counts based on filtered tasks, not just all tasks
    List<Task> tasksToCount = searchQuery.isEmpty ? tasks : filteredTasks;
    
    totalAllotted.value = tasksToCount.where((task) => task.status == TaskStatus.allotted).length;
    totalCompleted.value = tasksToCount.where((task) => task.status == TaskStatus.completed).length;
    totalClientWaiting.value = tasksToCount.where((task) => task.status == TaskStatus.client_waiting).length;
    totalReallotted.value = tasksToCount.where((task) => task.status == TaskStatus.re_alloted).length;
    pendingCount.value = tasksToCount.where((task) => task.status == TaskStatus.pending).length;
    
    // Calculate priority counts
    highPriorityCount.value = tasksToCount.where((task) => task.priority == TaskPriority.high).length;
    mediumPriorityCount.value = tasksToCount.where((task) => task.priority == TaskPriority.medium).length;
    lowPriorityCount.value = tasksToCount.where((task) => task.priority == TaskPriority.low).length;
    
    // Calculate allocation counts
    String currentUserId = UserController.instance.user.value.id.toString();
    allottedByMeCount.value = tasksToCount.where((task) => 
        task.allottedById == currentUserId).length;
    allottedToMeCount.value = tasksToCount.where((task) => 
        task.allottedToId == currentUserId).length;
    
    print("Task counts updated: allotted=${totalAllotted.value}, completed=${totalCompleted.value}, allottedByMe=${allottedByMeCount.value}, allottedToMe=${allottedToMeCount.value}");
  }
  
  void _applyFiltersAndSort() {
    // First apply search query
    var result = tasks.where((task) {
      if (searchQuery.isEmpty) return true;
      
      final query = searchQuery.value.toLowerCase();
      return (task.taskName.toLowerCase().contains(query) ||
             (task.client?.toLowerCase().contains(query) ?? false) ||
             (task.fileNo?.toLowerCase().contains(query) ?? false) ||
             (task.allottedBy?.toLowerCase().contains(query) ?? false) ||
             (task.allottedTo?.toLowerCase().contains(query) ?? false) ||
             (task.instructions?.toLowerCase().contains(query) ?? false) ||
             (task.financialYear?.toLowerCase().contains(query) ?? false)
             );
    }).toList();
    
    // Then apply status filter
    if (activeFilters.isNotEmpty) {
      result = result.where((task) {
        return activeFilters.any((filter) {
          switch (filter) {
            case 'allotted':
              return task.status == TaskStatus.allotted;
            case 'completed':
              return task.status == TaskStatus.completed;
            case 'client_waiting':
              return task.status == TaskStatus.client_waiting;
            case 're_alloted':
              return task.status == TaskStatus.re_alloted;
            case 'pending':
              return task.status == TaskStatus.pending;
            case 'high':
              return task.priority == TaskPriority.high;
            case 'medium':
              return task.priority == TaskPriority.medium;
            case 'low':
              return task.priority == TaskPriority.low;
            case 'allotted_by_me':
              return task.allottedById == UserController.instance.user.value.id.toString();
            case 'allotted_to_me':
              return task.allottedToId == UserController.instance.user.value.id.toString();
            default:
              return false;
          }
        });
      }).toList();
    }
    
    // Finally apply sorting
    result.sort((a, b) {
      int comparison = 0;
      
      switch (sortBy.value) {
        case 'name':
          comparison = a.taskName.compareTo(b.taskName);
          break;
        case 'client':
          comparison = (a.client ?? '').compareTo(b.client ?? '');
          break;
        case 'priority':
          comparison = (a.priority?.index ?? 0).compareTo(b.priority?.index ?? 0);
          break;
        case 'status':
          comparison = (a.status?.index ?? 0).compareTo(b.status?.index ?? 0);
          break;
        case 'date':
          // Sort by allotted date, defaulting to now if null
          final aDate = a.allottedDate ?? DateTime.now();
          final bDate = b.allottedDate ?? DateTime.now();
          comparison = aDate.compareTo(bDate);
          break;
        default:
          comparison = 0;
      }
      
      return sortAscending.value ? comparison : -comparison;
    });
    
    filteredTasks.value = result;
    
    // Update counts based on search results
    if (searchQuery.isNotEmpty) {
      // If there's a search query, update the counts based on search results
      filteredTasks = RxList(result);
      _updateTaskCounts();
    }
    
    print("Applied filters: search=${searchQuery.value}, filter=${activeFilters.toString()}");
    print("Filtered tasks count: ${filteredTasks.length}");
    
    // Reset to first page when filters change
    currentPage.value = 0;
    
    // Call paginate to update the paginated tasks
    _paginate();
  }
  
  void _paginate() {
    final startIndex = currentPage.value * _itemsPerPage;
    
    if (filteredTasks.isEmpty) {
      paginatedTasks.value = [];
      print("No tasks to paginate");
      return;
    }
    
    // Make sure we don't go out of bounds
    final endIndex = (startIndex + _itemsPerPage < filteredTasks.length) 
        ? startIndex + _itemsPerPage 
        : filteredTasks.length;
        
    if (startIndex >= filteredTasks.length) {
      // This can happen if we were on the last page and then filter reduced results
      currentPage.value = 0;
      _paginate();
      return;
    }
    
    paginatedTasks.value = filteredTasks.sublist(startIndex, endIndex);
    print("Paginated tasks updated: showing ${paginatedTasks.length} tasks from index $startIndex to ${endIndex-1}");
  }
}