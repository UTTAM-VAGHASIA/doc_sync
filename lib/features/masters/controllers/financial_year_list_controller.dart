import 'package:doc_sync/features/masters/models/financial_year_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/full_screen_loader.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class FinancialYearListController extends GetxController {
  
  static FinancialYearListController get instance => Get.find<FinancialYearListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  // Lists for financial years
  RxList<FinancialYear> financialYears = <FinancialYear>[].obs;
  RxList<FinancialYear> filteredFinancialYears = <FinancialYear>[].obs;
  RxList<FinancialYear> paginatedFinancialYears = <FinancialYear>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'all'.obs; // Default to show original API order
  RxBool sortAscending = true.obs;
  
  // Original order from API
  RxList<FinancialYear> originalFinancialYears = <FinancialYear>[].obs;
  
  // Pagination
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredFinancialYears.isEmpty 
    ? 1 
    : (filteredFinancialYears.length / _itemsPerPage).ceil();
  
  int get totalFinancialYearsCount => filteredFinancialYears.length;

  @override
  void onInit() {
    super.onInit();
    fetchFinancialYears();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchFinancialYears() async {
    try {
      isLoading.value = true;
      financialYears.clear();
      filteredFinancialYears.clear();
      paginatedFinancialYears.clear();
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchFinancialYears);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("financial_year_master", method: "GET");

      if (data['success']) {
        final financialYearsListData = data['data'];
        print("Financial Year list API response: $financialYearsListData");
        final financialYearsList = financialYearsListData.map<FinancialYear>((json) => FinancialYear.fromJson(json as Map<String, dynamic>)).toList();
        financialYears.value = financialYearsList;
        // Store the original order from API
        originalFinancialYears.value = List.from(financialYearsList);
        _applyFiltersAndSort();
        print("Fetched ${financialYears.length} financial years");
      } else {
        AppLoaders.errorSnackBar(
          title: "Financial Year List Error",
          message: data['message'] ?? "Failed to load financial year data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Financial Year List Error",
        message: "Error loading financial years: ${e.toString()}",
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
  
  void _applyFiltersAndSort() {
    // 1. Apply search filter
    if (searchQuery.isEmpty) {
      filteredFinancialYears.value = List.from(financialYears);
    } else {
      filteredFinancialYears.value = financialYears.where((financialYear) {
        final query = searchQuery.value.toLowerCase();
        return financialYear.year.toLowerCase().contains(query) ||
               financialYear.addBy.toLowerCase().contains(query);
      }).toList();
    }
    
    // 2. Apply sorting (if not 'all')
    if (sortBy.value != 'all') {
      filteredFinancialYears.sort((a, b) {
        int comparison = 0;
        switch (sortBy.value) {
          case 'year':
            comparison = a.year.compareTo(b.year);
            break;
          case 'add_by':
            comparison = a.addBy.compareTo(b.addBy);
            break;
          case 'created_on':
            comparison = a.createdOn.compareTo(b.createdOn);
            break;
          default:
            comparison = 0; // No sorting for 'all'
        }
        return sortAscending.value ? comparison : -comparison;
      });
    } else {
      // For 'all', preserve the original API order (for filtered items)
      // First get all the filtered IDs
      final filteredIds = filteredFinancialYears.map((fy) => fy.fId).toSet();
      
      // Then reorder based on original sequence
      filteredFinancialYears.value = originalFinancialYears
          .where((fy) => filteredIds.contains(fy.fId))
          .toList();
    }
    
    // Apply pagination
    _paginate();
  }
  
  void _paginate() {
    final startIndex = currentPage.value * itemsPerPage;
    final endIndex = (currentPage.value + 1) * itemsPerPage;
    
    if (startIndex >= filteredFinancialYears.length) {
      paginatedFinancialYears.value = [];
    } else {
      paginatedFinancialYears.value = filteredFinancialYears.sublist(
        startIndex,
        endIndex > filteredFinancialYears.length ? filteredFinancialYears.length : endIndex
      );
    }
  }
  
  // Method to view details of a specific financial year
  void viewFinancialYearDetails(FinancialYear financialYear) {
    // This would typically navigate to a financial year details screen
    Get.toNamed('/financial-year-details', arguments: financialYear);
  }
  
  // Method to edit a financial year
  void editFinancialYear(FinancialYear financialYear) {
    // Navigate to edit financial year screen with financial year data
    Get.toNamed('/edit-financial-year', arguments: financialYear);
  }
  
  // Method to delete a financial year
  Future<void> deleteFinancialYear(String financialYearId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => deleteFinancialYear(financialYearId));
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }
      
      // Show confirmation dialog
      final shouldDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Financial Year'),
          content: const Text('Are you sure you want to delete this financial year?'),
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
        "delete_financial_year",
        method: "POST",
        fields: {
          "f_id": financialYearId,
        },
      );
      
      AppFullScreenLoader.stopLoading();
      
      if (data['success']) {
        AppLoaders.successSnackBar(
          title: "Success", 
          message: data['message'] ?? "Financial year deleted successfully"
        );
        // Refresh the list
        fetchFinancialYears();
      } else {
        AppLoaders.errorSnackBar(
          title: "Error", 
          message: data['message'] ?? "Failed to delete financial year"
        );
      }
    } catch (e) {
      AppFullScreenLoader.stopLoading();
      AppLoaders.errorSnackBar(
        title: "Error",
        message: "Error deleting financial year: ${e.toString()}",
      );
    }
  }
} 