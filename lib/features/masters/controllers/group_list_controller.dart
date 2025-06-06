import 'package:doc_sync/features/masters/models/group_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/full_screen_loader.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GroupListController extends GetxController {
  
  static GroupListController get instance => Get.find<GroupListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  // Lists for groups
  RxList<Group> groups = <Group>[].obs;
  RxList<Group> filteredGroups = <Group>[].obs;
  RxList<Group> paginatedGroups = <Group>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'all'.obs; // Default to show original API order
  RxBool sortAscending = true.obs;
  
  // Original order from API
  RxList<Group> originalGroups = <Group>[].obs;
  
  // Pagination
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredGroups.isEmpty 
    ? 1 
    : (filteredGroups.length / _itemsPerPage).ceil();
  
  // Group status counts
  RxInt totalEnabledGroups = 0.obs;
  RxInt totalDisabledGroups = 0.obs;
  int get totalGroupsCount => filteredGroups.length;

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchGroups() async {
    try {
      isLoading.value = true;
      groups.clear();
      filteredGroups.clear();
      paginatedGroups.clear();
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchGroups);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("get_client_group_list", method: "GET");

      if (data['success']) {
        final groupsListData = data['data'];
        print("Group list API response: $groupsListData");
        final groupsList = groupsListData.map<Group>((json) => Group.fromJson(json as Map<String, dynamic>)).toList();
        groups.value = groupsList;
        // Store the original order from API
        originalGroups.value = List.from(groupsList);
        _updateGroupCounts();
        _applyFiltersAndSort();
        print("Fetched ${groups.length} groups");
      } else {
        AppLoaders.errorSnackBar(
          title: "Group List Error",
          message: data['message'] ?? "Failed to load group data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Group List Error",
        message: "Error loading groups: ${e.toString()}",
      );
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateSearch(String query) {
    searchQuery.value = query;
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
  
  void _updateGroupCounts() {
    // Calculate status counts for enabled/disabled groups
    List<Group> groupsToCount = searchQuery.isEmpty ? groups : filteredGroups;
    
    totalEnabledGroups.value = groupsToCount.where((group) => group.status.toLowerCase() == 'enable').length;
    totalDisabledGroups.value = groupsToCount.where((group) => group.status.toLowerCase() == 'disable').length;
  }
  
  void _applyFiltersAndSort() {
    // 1. Apply search filter
    if (searchQuery.isEmpty) {
      filteredGroups.value = List.from(groups);
    } else {
      filteredGroups.value = groups.where((group) {
        final query = searchQuery.value.toLowerCase();
        return group.groupName.toLowerCase().contains(query) ||
               group.clientName.toLowerCase().contains(query);
      }).toList();
    }
    
    // 2. Apply status filters if active
    if (activeFilters.isNotEmpty) {
      filteredGroups.value = filteredGroups.where((group) {
        if (activeFilters.contains('enable') && group.status.toLowerCase() == 'enable') return true;
        if (activeFilters.contains('disable') && group.status.toLowerCase() == 'disable') return true;
        return false;
      }).toList();
    }
    
    // 3. Apply sorting (if not 'all')
    if (sortBy.value != 'all') {
      filteredGroups.sort((a, b) {
        int comparison = 0;
        switch (sortBy.value) {
          case 'group_name':
            comparison = a.groupName.compareTo(b.groupName);
            break;
          case 'client_name':
            comparison = a.clientName.compareTo(b.clientName);
            break;
          case 'status':
            comparison = a.status.compareTo(b.status);
            break;
          default:
            comparison = 0; // No sorting for 'all'
        }
        return sortAscending.value ? comparison : -comparison;
      });
    } else {
      // For 'all', preserve the original API order (for filtered items)
      // First get all the filtered IDs
      final filteredIds = filteredGroups.map((g) => g.id).toSet();
      
      // Then reorder based on original sequence
      filteredGroups.value = originalGroups
          .where((g) => filteredIds.contains(g.id))
          .toList();
    }
    
    // Update counts based on filtered results
    _updateGroupCounts();
    
    // Apply pagination
    _paginate();
  }
  
  void _paginate() {
    final startIndex = currentPage.value * itemsPerPage;
    final endIndex = (currentPage.value + 1) * itemsPerPage;
    
    if (startIndex >= filteredGroups.length) {
      paginatedGroups.value = [];
    } else {
      paginatedGroups.value = filteredGroups.sublist(
        startIndex,
        endIndex > filteredGroups.length ? filteredGroups.length : endIndex
      );
    }
  }
  
  // Method to view details of a specific group
  void viewGroupDetails(Group group) {
    // This would typically navigate to a group details screen
    Get.toNamed('/group-details', arguments: group);
  }
  
  // Method to edit a group
  void editGroup(Group group) {
    // Navigate to edit group screen with group data
    Get.toNamed('/edit-group', arguments: group);
  }
  
  // Method to delete a group
  Future<void> deleteGroup(String groupId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => deleteGroup(groupId));
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }
      
      // Show confirmation dialog
      final shouldDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Group'),
          content: const Text('Are you sure you want to delete this group?'),
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
        "delete_client_group",
        method: "POST",
        fields: {
          "id": groupId,
        },
      );
      
      AppFullScreenLoader.stopLoading();
      
      if (data['success']) {
        AppLoaders.successSnackBar(
          title: "Success",
          message: data['message'] ?? "Group deleted successfully",
        );
        fetchGroups(); // Refresh the list
      } else {
        AppLoaders.errorSnackBar(
          title: "Delete Failed",
          message: data['message'] ?? "Failed to delete group",
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