import 'package:doc_sync/features/masters/models/task_master_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/full_screen_loader.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TaskMasterListController extends GetxController {
  
  static TaskMasterListController get instance => Get.find<TaskMasterListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  // Lists for task masters
  RxList<TaskMaster> taskMasters = <TaskMaster>[].obs;
  RxList<TaskMaster> filteredTaskMasters = <TaskMaster>[].obs;
  RxList<TaskMaster> paginatedTaskMasters = <TaskMaster>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'all'.obs; // Default to show original API order
  RxBool sortAscending = true.obs;
  
  // Original order from API
  RxList<TaskMaster> originalTaskMasters = <TaskMaster>[].obs;
  
  // Pagination - Changed to match GroupList indexing (1-based)
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredTaskMasters.isEmpty 
    ? 1 
    : (filteredTaskMasters.length / _itemsPerPage).ceil();
  
  // Status counts
  RxInt totalEnabledTaskMasters = 0.obs;
  RxInt totalDisabledTaskMasters = 0.obs;
  int get totalTaskMastersCount => filteredTaskMasters.length;

  @override
  void onInit() {
    super.onInit();
    fetchTaskMasters();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchTaskMasters() async {
    try {
      isLoading.value = true;
      taskMasters.clear();
      filteredTaskMasters.clear();
      paginatedTaskMasters.clear();
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchTaskMasters);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("task_master", method: "GET");

      if (data['success']) {
        final taskMastersData = data['data'];
        final taskMastersList = taskMastersData.map<TaskMaster>(
          (json) => TaskMaster.fromJson(json as Map<String, dynamic>)
        ).toList();
        
        taskMasters.value = taskMastersList;
        // Store the original order from API
        originalTaskMasters.value = List.from(taskMastersList);
        _updateTaskMasterCounts();
        _applyFiltersAndSort();
        print("Fetched ${taskMasters.length} task masters");
      } else {
        AppLoaders.errorSnackBar(
          title: "Task Master List Error",
          message: data['message'] ?? "Failed to load task master data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Task Master List Error",
        message: "Error loading task masters: ${e.toString()}",
      );
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 0; // Reset to first page when searching
  }
  
  void updateFilter(String filter) {
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
    } else {
      // If new sort field is selected, set default direction
      sortBy.value = sort;
      sortAscending.value = true;
    }
    currentPage.value = 0; // Reset to first page when sort changes
    _applyFiltersAndSort();
  }
  
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
      _paginate(); // Force immediate update
      paginatedTaskMasters.refresh(); // Force UI refresh
    }
  }
  
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      _paginate(); // Force immediate update
      paginatedTaskMasters.refresh(); // Force UI refresh
    }
  }
  
  void _updateTaskMasterCounts() {
    // Calculate status counts for enabled/disabled task masters
    List<TaskMaster> taskMastersToCount = searchQuery.isEmpty ? taskMasters : filteredTaskMasters;
    
    totalEnabledTaskMasters.value = taskMastersToCount.where(
      (taskMaster) => taskMaster.status.toLowerCase() == 'enable'
    ).length;
    
    totalDisabledTaskMasters.value = taskMastersToCount.where(
      (taskMaster) => taskMaster.status.toLowerCase() == 'disable'
    ).length;
  }
  
  void _applyFiltersAndSort() {
    // 1. Apply search filter
    if (searchQuery.isEmpty) {
      filteredTaskMasters.value = List.from(taskMasters);
    } else {
      filteredTaskMasters.value = taskMasters.where((taskMaster) {
        final query = searchQuery.value.toLowerCase();
        return taskMaster.taskName.toLowerCase().contains(query) ||
               taskMaster.id.toLowerCase().contains(query);
      }).toList();
    }
    
    // 2. Apply status filters if active
    if (activeFilters.isNotEmpty) {
      filteredTaskMasters.value = filteredTaskMasters.where((taskMaster) {
        if (activeFilters.contains('enable') && taskMaster.status.toLowerCase() == 'enable') return true;
        if (activeFilters.contains('disable') && taskMaster.status.toLowerCase() == 'disable') return true;
        return false;
      }).toList();
    }
    
    // 3. Apply sorting (if not 'all')
    if (sortBy.value != 'all') {
      filteredTaskMasters.sort((a, b) {
        int comparison = 0;
        switch (sortBy.value) {
          case 'task_name':
            comparison = a.taskName.compareTo(b.taskName);
            break;
          case 'status':
            comparison = a.status.compareTo(b.status);
            break;
          case 'date_time':
            comparison = a.dateTime.compareTo(b.dateTime);
            break;
          default:
            comparison = 0; // No sorting for 'all'
        }
        return sortAscending.value ? comparison : -comparison;
      });
    } else {
      // For 'all', preserve the original API order (for filtered items)
      // First get all the filtered IDs
      final filteredIds = filteredTaskMasters.map((tm) => tm.id).toSet();
      
      // Then reorder based on original sequence
      filteredTaskMasters.value = originalTaskMasters
          .where((tm) => filteredIds.contains(tm.id))
          .toList();
    }
    
    // Update counts based on filtered results
    _updateTaskMasterCounts();
    
    // Apply pagination
    _paginate();
    // Force UI refresh
    filteredTaskMasters.refresh();
    paginatedTaskMasters.refresh();
  }
  
  void _paginate() {
    if (filteredTaskMasters.isEmpty) {
      paginatedTaskMasters.clear();
      return;
    }
  
    final startIndex = currentPage.value * itemsPerPage;
    if (startIndex >= filteredTaskMasters.length) {
      // If current page would be empty (e.g. after filtering), go back to first page
      currentPage.value = 0;
      _paginate(); // Call again with corrected page
      return;
    }
    
    final endIndex = startIndex + itemsPerPage;
    final adjustedEndIndex = endIndex > filteredTaskMasters.length 
        ? filteredTaskMasters.length 
        : endIndex;
    
    paginatedTaskMasters.value = filteredTaskMasters.sublist(startIndex, adjustedEndIndex);
  }
  
  // Method to edit a task master
  void editTaskMaster(TaskMaster taskMaster) {
    // Navigate to edit screen with task master data
    Get.toNamed('/edit-task-master', arguments: taskMaster);
  }
  
  // Method to delete a task master
  Future<void> deleteTaskMaster(String taskMasterId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => deleteTaskMaster(taskMasterId));
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }
      
      // Show confirmation dialog
      final shouldDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Task Master'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      
      if (shouldDelete != true) return;
      
      AppFullScreenLoader.popUpCircular();
      
      final data = await AppHttpHelper().sendMultipartRequest(
        "delete_task_master",
        method: "POST",
        fields: {
          "id": taskMasterId,
        },
      );
      
      AppFullScreenLoader.stopLoading();
      
      if (data['success']) {
        AppLoaders.successSnackBar(
          title: "Success",
          message: data['message'] ?? "Task master deleted successfully",
        );
        fetchTaskMasters(); // Refresh the list
      } else {
        AppLoaders.errorSnackBar(
          title: "Delete Failed",
          message: data['message'] ?? "Failed to delete task master",
        );
      }
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(
        title: "Delete Error",
        message: e.toString(),
      );
    }
  }

  // Method to jump to a specific page
  void goToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < totalPages) {
      currentPage.value = pageIndex;
      _paginate(); // Force immediate update
      paginatedTaskMasters.refresh(); // Force UI refresh
    }
  }
  
  // Method to skip multiple pages backward
  void skipPagesBackward() {
    int skipSize = _calculateSkipSize();
    int targetPage = (currentPage.value - skipSize).clamp(0, totalPages - 1);
    goToPage(targetPage);
  }
  
  // Method to skip multiple pages forward
  void skipPagesForward() {
    int skipSize = _calculateSkipSize();
    int targetPage = (currentPage.value + skipSize).clamp(0, totalPages - 1);
    goToPage(targetPage);
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
} 