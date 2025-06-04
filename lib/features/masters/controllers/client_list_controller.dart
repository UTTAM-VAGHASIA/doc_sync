import 'dart:convert';

import 'package:doc_sync/features/masters/models/client_model.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ClientListController extends GetxController {
  
  static ClientListController get instance => Get.find<ClientListController>();

  // Global key for LiquidPullToRefresh
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();

  // Lists for clients
  RxList<Client> clients = <Client>[].obs;
  RxList<Client> filteredClients = <Client>[].obs;
  RxList<Client> paginatedClients = <Client>[].obs;

  // Loading state
  RxBool isLoading = false.obs;

  // Search and filter
  RxString searchQuery = ''.obs;
  RxSet<String> activeFilters = <String>{}.obs;
  
  // Sorting
  RxString sortBy = 'firm_name'.obs; // Default sort by firm name
  RxBool sortAscending = true.obs;
  
  // Pagination
  RxInt currentPage = 0.obs;
  int _itemsPerPage = 10;
  int get itemsPerPage => _itemsPerPage;
  set itemsPerPage(int value) {
    _itemsPerPage = value;
    _applyFiltersAndSort();
  }
  
  int get totalPages => filteredClients.isEmpty 
    ? 1 
    : (filteredClients.length / _itemsPerPage).ceil();
  
  // Client status counts
  RxInt totalActiveClients = 0.obs;
  RxInt totalInactiveClients = 0.obs;
  int get totalClientsCount => filteredClients.length;

  @override
  void onInit() {
    super.onInit();
    fetchClients();
    
    // Set up listeners for search, filter and pagination changes
    ever(searchQuery, (_) => _applyFiltersAndSort());
    ever(activeFilters, (_) => _applyFiltersAndSort());
    ever(sortBy, (_) => _applyFiltersAndSort());
    ever(sortAscending, (_) => _applyFiltersAndSort());
    ever(currentPage, (_) => _paginate());
  }

  Future<void> fetchClients() async {
    try {
      isLoading.value = true;
      clients.clear();
      filteredClients.clear();
      paginatedClients.clear();
      
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchClients);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        isLoading.value = false;
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("get_client_list", method: "GET");

      if (data['success']) {
        final clientsListData = data['data'];
        final clientsList = clientsListData.map<Client>((json) => Client.fromJson(json as Map<String, dynamic>)).toList();
        clients.value = clientsList;
        _updateClientCounts();
        _applyFiltersAndSort();
        print("Fetched ${clients.length} clients");
      } else {
        AppLoaders.errorSnackBar(
          title: "Client List Error",
          message: data['message'] ?? "Failed to load client data",
        );
        print(data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Client List Error",
        message: "Error loading clients: ${e.toString()}",
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
  
  void _updateClientCounts() {
    // Calculate status counts for active/inactive clients
    List<Client> clientsToCount = searchQuery.isEmpty ? clients : filteredClients;
    
    totalActiveClients.value = clientsToCount.where((client) => client.status.toLowerCase() == 'active').length;
    totalInactiveClients.value = clientsToCount.where((client) => client.status.toLowerCase() == 'inactive').length;
  }
  
  void _applyFiltersAndSort() {
    // 1. Apply search filter
    if (searchQuery.isEmpty) {
      filteredClients.value = List.from(clients);
    } else {
      filteredClients.value = clients.where((client) {
        final query = searchQuery.value.toLowerCase();
        return client.firmName.toLowerCase().contains(query) ||
               client.fileNo.toLowerCase().contains(query) ||
               client.contactPerson.toLowerCase().contains(query) ||
               client.email.toLowerCase().contains(query) ||
               client.contactNo.contains(query);
      }).toList();
    }
    
    // 2. Apply status filters if active
    if (activeFilters.isNotEmpty) {
      filteredClients.value = filteredClients.where((client) {
        if (activeFilters.contains('active') && client.status.toLowerCase() == 'active') return true;
        if (activeFilters.contains('inactive') && client.status.toLowerCase() == 'inactive') return true;
        return false;
      }).toList();
    }
    
    // 3. Apply sorting
    filteredClients.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'firm_name':
          comparison = a.firmName.compareTo(b.firmName);
          break;
        case 'file_no':
          comparison = a.fileNo.compareTo(b.fileNo);
          break;
        case 'contact_person':
          comparison = a.contactPerson.compareTo(b.contactPerson);
          break;
        case 'email':
          comparison = a.email.compareTo(b.email);
          break;
        case 'contact_no':
          comparison = a.contactNo.compareTo(b.contactNo);
          break;
        default:
          comparison = a.firmName.compareTo(b.firmName);
      }
      return sortAscending.value ? comparison : -comparison;
    });
    
    // Update counts based on filtered results
    _updateClientCounts();
    
    // Apply pagination
    _paginate();
  }
  
  void _paginate() {
    final startIndex = currentPage.value * itemsPerPage;
    final endIndex = (currentPage.value + 1) * itemsPerPage;
    
    if (startIndex >= filteredClients.length) {
      paginatedClients.value = [];
    } else {
      paginatedClients.value = filteredClients.sublist(
        startIndex,
        endIndex > filteredClients.length ? filteredClients.length : endIndex
      );
    }
  }
  
  // Method to open details of a specific client
  void openClientDetails(Client client) {
    // This would typically navigate to a client details screen
    Get.toNamed('/client-details', arguments: client);
  }
  
  // Method to edit a client
  void editClient(Client client) {
    // Navigate to edit client screen with client data
    Get.toNamed('/edit-client', arguments: client);
  }
  
  // Method to delete a client
  Future<void> deleteClient(String clientId) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => deleteClient(clientId));
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest(
        "delete_client", 
        method: "POST", 
        fields: {'data': jsonEncode({"client_id": clientId})}
      );

      if (data['success']) {
        AppLoaders.successSnackBar(
          title: "Success", 
          message: data['message'] ?? "Client deleted successfully"
        );
        // Refresh client list
        fetchClients();
      } else {
        AppLoaders.errorSnackBar(
          title: "Error", 
          message: data['message'] ?? "Failed to delete client"
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Error",
        message: "Error deleting client: ${e.toString()}",
      );
    }
  }
} 