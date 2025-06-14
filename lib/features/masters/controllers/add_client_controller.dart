import 'package:doc_sync/features/masters/models/group_model.dart';
import 'package:doc_sync/features/masters/models/accountant_model.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:doc_sync/utils/local_storage/storage_utility.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AddClientController extends GetxController {
  // Form Key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  // Loading States
  final RxBool isSubmitting = false.obs;
  final RxBool isDraftLoading = false.obs;
  final RxBool isDraftSaving = false.obs;
  final RxBool isDraftClearing = false.obs;
  final RxBool isLoadingGroups = false.obs;
  final RxBool isLoadingAccountants = false.obs;

  // Form Values
  final RxString fileNo = ''.obs;
  final RxString firmName = ''.obs;
  final RxString contactPerson = ''.obs;
  final RxString gstn = ''.obs;
  final RxString tan = ''.obs;
  final RxString email = ''.obs;
  final RxString contactNo = ''.obs;
  final RxString pan = ''.obs;
  final RxString otherId = ''.obs;
  final RxString operation = ''.obs;
  final RxString status = 'Active'.obs; // Default status

  // Group-related properties
  final RxList<Group> groups = <Group>[].obs;
  final Rxn<Group> selectedGroup = Rxn<Group>();

  // Accountant-related properties
  final RxList<Accountant> accountants = <Accountant>[].obs;
  final Rxn<Accountant> selectedAccountant = Rxn<Accountant>();

  @override
  void onInit() {
    super.onInit();
    fetchGroups();
    fetchAccountants();
  }

  // Method to load data
  Future<void> loadData() async {
    try {
      // Add your data loading logic here
      fetchGroups();
      fetchAccountants();
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Placeholder delay
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    }
  }

  // Fetch groups from API
  Future<void> fetchGroups() async {
    isLoadingGroups.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchGroups);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("get_group_list", method: "GET");

      if (data['success']) {
        final groupsData = data['data'] as List<dynamic>;
        groups.clear();
        groups.addAll(groupsData.map((json) => Group.fromJson(json as Map<String, dynamic>)));
        
        // Select the first active group by default if available
        final activeGroups = groups.where((group) => group.status.toLowerCase() == 'active').toList();
        if (activeGroups.isNotEmpty) {
          selectedGroup.value = activeGroups.first;
        }
        
        print("Fetched ${groups.length} groups");
      } else {
        AppLoaders.errorSnackBar(
          title: "Group List Error",
          message: data['message'] ?? "Failed to load groups",
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Group List Error",
        message: "Error loading groups: ${e.toString()}",
      );
    } finally {
      isLoadingGroups.value = false;
    }
  }

  // Fetch accountants from API
  Future<void> fetchAccountants() async {
    isLoadingAccountants.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchAccountants);
        AppLoaders.customToast(message: "Offline. Will retry when back online.");
        return;
      }

      final data = await AppHttpHelper().sendMultipartRequest("get_accountant_list", method: "GET");

      if (data['success']) {
        final accountantsData = data['data'] as List<dynamic>;
        accountants.clear();
        accountants.addAll(accountantsData.map((json) => Accountant.fromJson(json as Map<String, dynamic>)));
        
        print("Fetched ${accountants.length} accountants");
      } else {
        AppLoaders.errorSnackBar(
          title: "Accountant List Error",
          message: data['message'] ?? "Failed to load accountants",
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: "Accountant List Error",
        message: "Error loading accountants: ${e.toString()}",
      );
    } finally {
      isLoadingAccountants.value = false;
    }
  }

  // Reset all form fields
  void resetForm() {
    fileNo.value = '';
    firmName.value = '';
    contactPerson.value = '';
    gstn.value = '';
    tan.value = '';
    email.value = '';
    contactNo.value = '';
    pan.value = '';
    otherId.value = '';
    operation.value = '';
    status.value = 'Active';
    
    // Reselect the first active group as default
    final activeGroups = groups.where((group) => group.status.toLowerCase() == 'active').toList();
    if (activeGroups.isNotEmpty) {
      selectedGroup.value = activeGroups.first;
    } else {
      selectedGroup.value = null;
    }
  }

  // Form validation logic
  bool validateForm() {
    if (firmName.value.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please enter firm name',
      );
      return false;
    }

    if (contactPerson.value.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please enter contact person name',
      );
      return false;
    }

    if (email.value.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please enter email address',
      );
      return false;
    }

    if (contactNo.value.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please enter contact number',
      );
      return false;
    }

    if (fileNo.value.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please enter file number',
      );
      return false;
    }

    return true;
  }

  // Method to save the current form state as a draft
  Future<void> saveDraft() async {
    isDraftSaving.value = true;
    try {
      final draft = _collectFormData();
      await StorageUtility.instance().writeData(
        'add_client_draft',
        jsonEncode(draft),
      );
      AppLoaders.successSnackBar(
        title: 'Draft Saved',
        message: 'You can load it later.',
      );
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to save draft: ${e.toString()}',
      );
    } finally {
      isDraftSaving.value = false;
    }
  }

  // Method to load a previously saved draft
  Future<void> loadDraft() async {
    isDraftLoading.value = true;
    try {
      final jsonData = await StorageUtility.instance().readData(
        'add_client_draft',
      );
      if (jsonData != null) {
        final draft = jsonDecode(jsonData);
        _applyFormData(draft);
        AppLoaders.successSnackBar(
          title: 'Draft Loaded',
          message: 'Form restored from draft.',
        );
      } else {
        AppLoaders.warningSnackBar(
          title: 'No Draft',
          message: 'No draft found.',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load draft.',
      );
    } finally {
      isDraftLoading.value = false;
    }
  }

  // Method to clear all form fields
  void clearForm() {
    resetForm();
    AppLoaders.successSnackBar(title: 'Success', message: 'Form cleared');
  }

  // Method to clear saved draft
  Future<void> clearDraft() async {
    isDraftClearing.value = true;
    try {
      await StorageUtility.instance().removeData('add_client_draft');
      AppLoaders.successSnackBar(
        title: 'Draft Cleared',
        message: 'Saved draft has been removed.',
      );
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to clear draft: ${e.toString()}',
      );
    } finally {
      isDraftClearing.value = false;
    }
  }

  /// Collects all form data into a map for draft saving
  Map<String, dynamic> _collectFormData() {
    return {
      'file_no': fileNo.value,
      'firm_name': firmName.value,
      'contact_person': contactPerson.value,
      'gstn': gstn.value,
      'tan': tan.value,
      'email_id': email.value,
      'contact_no': contactNo.value,
      'pan': pan.value,
      'other_id': otherId.value,
      'operation': operation.value,
      'status': status.value,
      'group_id': selectedGroup.value?.id ?? '',
      'accountant_id': selectedAccountant.value?.id ?? '',
    };
  }

  /// Applies draft data to form fields
  void _applyFormData(Map<String, dynamic> draft) {
    fileNo.value = draft['file_no'] ?? '';
    firmName.value = draft['firm_name'] ?? '';
    contactPerson.value = draft['contact_person'] ?? '';
    gstn.value = draft['gstn'] ?? '';
    tan.value = draft['tan'] ?? '';
    email.value = draft['email_id'] ?? '';
    contactNo.value = draft['contact_no'] ?? '';
    pan.value = draft['pan'] ?? '';
    otherId.value = draft['other_id'] ?? '';
    operation.value = draft['operation'] ?? '';
    status.value = draft['status'] ?? 'Active';
    
    // Set selected group if it exists in the draft
    final groupId = draft['group_id'];
    if (groupId != null && groupId != '') {
      selectedGroup.value = groups.firstWhereOrNull((group) => group.id == groupId);
    }

    // Set selected accountant if it exists in the draft
    final accountantId = draft['accountant_id'];
    if (accountantId != null && accountantId != '') {
      selectedAccountant.value = accountants.firstWhereOrNull((acc) => acc.id == accountantId);
    }
  }

  /// Submits the new client form
  Future<void> submitNewClient() async {
    if (!validateForm()) return;
    isSubmitting.value = true;
    await saveDraft();
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => submitNewClient());
        AppLoaders.customToast(
          message: 'Offline. Will retry when back online.',
        );
        return;
      }
      
      // Prepare the payload according to the required format
      final Map<String, dynamic> payload = {
        'firm_name': firmName.value,
        'contact_person': contactPerson.value,
        'contact_no': contactNo.value,
        'file_no': fileNo.value,
        'pan': pan.value,
        'other_id': otherId.value,
        'accountant_id': "11", // Hardcoded accountant ID value
        'groups_id': "43",
        'email_id': email.value,
        'gstn': gstn.value,
        'tan': tan.value,
      };
      
      print('[API REQUEST] add_client payload: ${jsonEncode(payload)}');
      
      final data = await AppHttpHelper().sendMultipartRequest(
        'add_client', // API endpoint
        method: 'POST',
        fields: {'data': jsonEncode(payload)},
      );
      
      print('[API RESPONSE] add_client: $data');
      
      if (data['success'] == true) {
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['message'] ?? 'Client added successfully',
        );
        resetForm();
        showPostSubmitDialog();
      } else {
        AppLoaders.errorSnackBar(
          title: 'Error',
          message: data['message'] ?? 'Failed to add client',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Shows a dialog after successful submission
  void showPostSubmitDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: AppColors.primary, size: 56),
              const SizedBox(height: 16),
              Text(
                'Client Added Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The client has been added successfully.\n\nWhat would you like to do next?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another Client'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        side: BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        Get.back(); // Close dialog, stay on form
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.list_alt),
                      label: const Text('View Client List'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed(AppRoutes.client); // Navigate to client list
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
