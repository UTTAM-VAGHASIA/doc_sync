import 'package:doc_sync/features/masters/models/sub_task_master_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/full_screen_loader.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class SubTaskMasterListController extends GetxController {
  
  static SubTaskMasterListController get instance => Get.find<SubTaskMasterListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  // Lists for sub task masters
  RxList<SubTaskMaster> subTaskMasters = <SubTaskMaster>[].obs;
  RxList<SubTaskMaster> filteredSubTaskMasters = <SubTaskMaster>[].obs;
  RxList<SubTaskMaster> paginatedSubTaskMasters = <SubTaskMaster>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'all'.obs; // Default to show original API order
  RxBool sortAscending = true.obs;
  
  // Original order from API
  RxList<SubTaskMaster> originalSubTaskMasters = <SubTaskMaster>[].obs;
  
  // Pagination - Using 1-based indexing to match GroupList
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredSubTaskMasters.isEmpty 
    ? 1 
    : (filteredSubTaskMasters.length / _itemsPerPage).ceil();
  
  // Status counts
  RxInt totalEnabledSubTaskMasters = 0.obs;
  RxInt totalDisabledSubTaskMasters = 0.obs;
  int get totalSubTaskMastersCount => filteredSubTaskMasters.length;

  @override
  void onInit() {
    super.onInit();
    fetchSubTaskMasters();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchSubTaskMasters() async {
    try {
      isLoading.value = true;
      subTaskMasters.clear();
      filteredSubTaskMasters.clear();
      paginatedSubTaskMasters.clear();
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchSubTaskMasters);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("sub_task_master", method: "GET");

      if (data['success']) {
        final subTaskMastersData = data['data'];
        final subTaskMastersList = subTaskMastersData.map<SubTaskMaster>(
          (json) => SubTaskMaster.fromJson(json as Map<String, dynamic>)
        ).toList();
        
        subTaskMasters.value = subTaskMastersList;
        // Store the original order from API
        originalSubTaskMasters.value = List.from(subTaskMastersList);
        _updateSubTaskMasterCounts();
        _applyFiltersAndSort();
        print("Fetched ${subTaskMasters.length} sub task masters");
      } else {
        AppLoaders.errorSnackBar(
          title: "Sub Task Master List Error",
          message: data['message'] ?? "Failed to load sub task master data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Sub Task Master List Error",
        message: "Error loading sub task masters: ${e.toString()}",
      );
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 0;
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
  }
  
  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      currentPage.value++;
    }
  }
  
  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }
  
  void _updateSubTaskMasterCounts() {
    // Calculate status counts for enabled/disabled sub task masters
    List<SubTaskMaster> subTaskMastersToCount = searchQuery.isEmpty ? subTaskMasters : filteredSubTaskMasters;
    
    totalEnabledSubTaskMasters.value = subTaskMastersToCount.where(
      (subTaskMaster) => subTaskMaster.status.toLowerCase() == 'enable'
    ).length;
    
    totalDisabledSubTaskMasters.value = subTaskMastersToCount.where(
      (subTaskMaster) => subTaskMaster.status.toLowerCase() == 'disable'
    ).length;
  }
  
  void _applyFiltersAndSort() {
    // 1. Apply search filter
    if (searchQuery.isEmpty) {
      filteredSubTaskMasters.value = List.from(subTaskMasters);
    } else {
      filteredSubTaskMasters.value = subTaskMasters.where((subTaskMaster) {
        final query = searchQuery.value.toLowerCase();
        return subTaskMaster.subTaskName.toLowerCase().contains(query) ||
               subTaskMaster.taskName.toLowerCase().contains(query) ||
               subTaskMaster.id.toLowerCase().contains(query);
      }).toList();
    }
    
    // 2. Apply status filters if active
    if (activeFilters.isNotEmpty) {
      filteredSubTaskMasters.value = filteredSubTaskMasters.where((subTaskMaster) {
        if (activeFilters.contains('enable') && subTaskMaster.status.toLowerCase() == 'enable') return true;
        if (activeFilters.contains('disable') && subTaskMaster.status.toLowerCase() == 'disable') return true;
        return false;
      }).toList();
    }
    
    // 3. Apply sorting (if not 'all')
    if (sortBy.value != 'all') {
      filteredSubTaskMasters.sort((a, b) {
        int comparison = 0;
        switch (sortBy.value) {
          case 'task_name':
            comparison = a.taskName.compareTo(b.taskName);
            break;
          case 'sub_task_name':
            comparison = a.subTaskName.compareTo(b.subTaskName);
            break;
          case 'amount':
            // Parse amount as double for numeric sorting
            final double aAmount = double.tryParse(a.amount) ?? 0;
            final double bAmount = double.tryParse(b.amount) ?? 0;
            comparison = aAmount.compareTo(bAmount);
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
      final filteredIds = filteredSubTaskMasters.map((stm) => stm.id).toSet();
      
      // Then reorder based on original sequence
      filteredSubTaskMasters.value = originalSubTaskMasters
          .where((stm) => filteredIds.contains(stm.id))
          .toList();
    }
    
    // Update counts based on filtered results
    _updateSubTaskMasterCounts();
    
    // Apply pagination
    _paginate();
  }
  
  void _paginate() {
    final startIndex = currentPage.value * itemsPerPage;
    final endIndex = (currentPage.value + 1) * itemsPerPage;
    
    if (startIndex >= filteredSubTaskMasters.length && filteredSubTaskMasters.isNotEmpty) {
      // If we're on a page that no longer exists (e.g., after filtering), go to first page
      currentPage.value = 0;
      _paginate();
    } else {
      paginatedSubTaskMasters.value = filteredSubTaskMasters.isEmpty ? [] : 
        filteredSubTaskMasters.sublist(
          startIndex,
          endIndex > filteredSubTaskMasters.length ? filteredSubTaskMasters.length : endIndex
        );
    }
  }
  
  // Method to edit a sub task master
  void editSubTaskMaster(SubTaskMaster subTaskMaster) {
    // Navigate to edit screen with sub task master data
    Get.toNamed('/edit-sub-task-master', arguments: subTaskMaster);
  }
  
  // Method to delete a sub task master
  Future<void> deleteSubTaskMaster(String subTaskMasterId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => deleteSubTaskMaster(subTaskMasterId));
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }
      
      // Show confirmation dialog
      final shouldDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Sub Task Master'),
          content: const Text('Are you sure you want to delete this sub task?'),
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
        "delete_sub_task_master",
        method: "POST",
        fields: {
          "id": subTaskMasterId,
        },
      );
      
      AppFullScreenLoader.stopLoading();
      
      if (data['success']) {
        AppLoaders.successSnackBar(
          title: "Success",
          message: data['message'] ?? "Sub task master deleted successfully",
        );
        fetchSubTaskMasters(); // Refresh the list
      } else {
        AppLoaders.errorSnackBar(
          title: "Delete Failed",
          message: data['message'] ?? "Failed to delete sub task master",
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