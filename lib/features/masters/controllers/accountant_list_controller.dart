import 'dart:convert';

import 'package:doc_sync/features/masters/models/accountant_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AccountantListController extends GetxController {
  
  static AccountantListController get instance => Get.find<AccountantListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  // Lists for accountants
  RxList<Accountant> accountants = <Accountant>[].obs;
  RxList<Accountant> filteredAccountants = <Accountant>[].obs;
  RxList<Accountant> paginatedAccountants = <Accountant>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'all'.obs; // Default sort to 'all'
  RxBool sortAscending = true.obs;
  
  // Original order from API
  RxList<Accountant> originalAccountants = <Accountant>[].obs;
  
  // Pagination
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredAccountants.isEmpty 
    ? 1 
    : (filteredAccountants.length / _itemsPerPage).ceil();
  
  // Accountant status counts
  RxInt totalEnabledAccountants = 0.obs;
  RxInt totalDisabledAccountants = 0.obs;
  int get totalAccountantsCount => filteredAccountants.length;

  @override
  void onInit() {
    super.onInit();
    fetchAccountants();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchAccountants() async {
    try {
      isLoading.value = true;
      accountants.clear();
      filteredAccountants.clear();
      paginatedAccountants.clear();
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchAccountants);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("accountant_master", method: "GET");

      if (data['success']) {
        final accountantsListData = data['data'];
        print("Accountant list API response: $accountantsListData");
        final accountantsList = accountantsListData.map<Accountant>((json) => Accountant.fromJson(json as Map<String, dynamic>)).toList();
        accountants.value = accountantsList;
        // Store the original order from API
        originalAccountants.value = List.from(accountantsList);
        _updateAccountantCounts();
        _applyFiltersAndSort();
        print("Fetched ${accountants.length} accountants");
      } else {
        AppLoaders.errorSnackBar(
          title: "Accountant List Error",
          message: data['message'] ?? "Failed to load accountant data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Accountant List Error",
        message: "Error loading accountants: ${e.toString()}",
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
      // For name fields, default to ascending
      sortAscending.value = true;
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
  
  void _updateAccountantCounts() {
    // Calculate status counts for enabled/disabled accountants
    List<Accountant> accountantsToCount = searchQuery.isEmpty ? accountants : filteredAccountants;
    
    totalEnabledAccountants.value = accountantsToCount.where((accountant) => accountant.status.toLowerCase() == 'enable').length;
    totalDisabledAccountants.value = accountantsToCount.where((accountant) => accountant.status.toLowerCase() == 'disable').length;
  }
  
  void _applyFiltersAndSort() {
    // 1. Apply search filter
    if (searchQuery.isEmpty) {
      filteredAccountants.value = List.from(accountants);
    } else {
      filteredAccountants.value = accountants.where((accountant) {
        final query = searchQuery.value.toLowerCase();
        return accountant.accountantName.toLowerCase().contains(query) ||
               accountant.contact1.toLowerCase().contains(query) ||
               accountant.contact2.toLowerCase().contains(query);
      }).toList();
    }
    
    // 2. Apply status filters if active
    if (activeFilters.isNotEmpty) {
      filteredAccountants.value = filteredAccountants.where((accountant) {
        if (activeFilters.contains('enable') && accountant.status.toLowerCase() == 'enable') return true;
        if (activeFilters.contains('disable') && accountant.status.toLowerCase() == 'disable') return true;
        return false;
      }).toList();
    }
    
    // 3. Apply sorting
    if (sortBy.value != 'all') {
      filteredAccountants.sort((a, b) {
        int comparison = 0;
        switch (sortBy.value) {
          case 'accountant_name':
            comparison = a.accountantName.compareTo(b.accountantName);
            break;
          case 'contact1':
            comparison = a.contact1.compareTo(b.contact1);
            break;
          case 'contact2':
            comparison = a.contact2.compareTo(b.contact2);
            break;
          case 'status':
            comparison = a.status.compareTo(b.status);
            break;
          default:
            comparison = a.accountantName.compareTo(b.accountantName);
        }
        return sortAscending.value ? comparison : -comparison;
      });
    }
    
    // Update counts based on filtered results
    _updateAccountantCounts();
    
    // Apply pagination
    _paginate();
  }
  
  void _paginate() {
    final startIndex = currentPage.value * itemsPerPage;
    final endIndex = (currentPage.value + 1) * itemsPerPage;
    
    if (startIndex >= filteredAccountants.length) {
      paginatedAccountants.value = [];
    } else {
      paginatedAccountants.value = filteredAccountants.sublist(
        startIndex,
        endIndex > filteredAccountants.length ? filteredAccountants.length : endIndex
      );
    }
  }
  
  // Method to view details of a specific accountant
  void viewAccountantDetails(Accountant accountant) {
    // This would typically navigate to a accountant details screen
    Get.toNamed('/accountant-details', arguments: accountant);
  }
  
  // Method to edit an accountant
  void editAccountant(Accountant accountant) {
    // Navigate to edit accountant screen with accountant data
    Get.toNamed('/edit-accountant', arguments: accountant);
  }
  
  // Method to delete an accountant
  Future<void> deleteAccountant(String accountantId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => deleteAccountant(accountantId));
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest(
        "delete_accountant", 
        method: "POST", 
        fields: {'data': jsonEncode({"accountant_id": accountantId})}
      );

      if (data['success']) {
        AppLoaders.successSnackBar(
          title: "Success", 
          message: data['message'] ?? "Accountant deleted successfully"
        );
        // Refresh accountant list
        fetchAccountants();
      } else {
        AppLoaders.errorSnackBar(
          title: "Error", 
          message: data['message'] ?? "Failed to delete accountant"
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Error",
        message: "Error deleting accountant: ${e.toString()}",
      );
    }
  }
} 