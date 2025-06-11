import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:doc_sync/common/widgets/loaders/loader_animation.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/client_selection_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/financial_year_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/staff_allotment_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/task_details_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/task_selection_section.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditTaskBottomSheet extends StatefulWidget {
  final Task task;

  const EditTaskBottomSheet({super.key, required this.task});

  @override
  State<EditTaskBottomSheet> createState() => _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends State<EditTaskBottomSheet> {
  late NewTaskController controller;
  bool isLoading = true;
  bool _isMounted = true;

  // Cancellation flags for API requests
  bool _cancelRequests = false;
  final List<Completer> _pendingCompleters = [];

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _isMounted = false;
    _cancelRequests = true;

    // Cancel any pending completers
    for (var completer in _pendingCompleters) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    super.dispose();
  }

  Future<void> _initializeController() async {
    // Check if controller already exists in GetX dependency injection
    if (Get.isRegistered<NewTaskController>()) {
      controller = Get.find<NewTaskController>();
    } else {
      // Create and register a new controller if it doesn't exist
      controller = NewTaskController();
      Get.put(controller);
    }

    // Wait for initial data loading to complete
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!_isMounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Load all the necessary data with cancellation handling
      await _safeApiCall(controller.fetchTasks());
      if (_cancelRequests) return;

      await _safeApiCall(controller.fetchClients());
      if (_cancelRequests) return;

      await _safeApiCall(controller.fetchFinancialYears());
      if (_cancelRequests) return;

      await _safeApiCall(controller.fetchStaff());
      if (_cancelRequests) return;

      // Pre-fill form with task data
      await _prefillTaskData();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (_isMounted && !_cancelRequests) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Wrap API calls in a cancellable operation
  Future<T?> _safeApiCall<T>(Future<T> apiFuture) async {
    if (_cancelRequests) return null;

    final completer = Completer<T?>();
    _pendingCompleters.add(completer);

    try {
      final result = await apiFuture;
      if (!_cancelRequests && !completer.isCompleted) {
        completer.complete(result);
        return result;
      }
    } catch (e) {
      if (!_cancelRequests && !completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    } finally {
      _pendingCompleters.remove(completer);
    }

    return null;
  }

  Future<void> _prefillTaskData() async {
    if (_cancelRequests || !_isMounted) return;

    // Set selected task
    controller.selectedTask.value = controller.tasks.firstWhereOrNull(
      (t) => t.taskId == widget.task.taskId,
    );

    // Wait for subtasks to load after task selection
    if (controller.selectedTask.value != null && !_cancelRequests) {
      await _safeApiCall(
        controller.fetchSubTasksForTask(controller.selectedTask.value!.taskId),
      );
      if (_cancelRequests) return;
    }

    // Set selected subtask
    controller.selectedSubTask.value = controller.subTasks.firstWhereOrNull(
      (s) => s.id == widget.task.subtaskId,
    );

    // Set selected client
    controller.selectedClient.value = controller.clients.firstWhereOrNull(
      (c) => c.clientId == widget.task.clientId,
    );

    // Set selected staff (allotted to)
    controller.selectedStaff.value = controller.staffList.firstWhereOrNull(
      (s) => s.staffId == widget.task.allottedToId,
    );

    // Set selected financial year
    controller.selectedFinancialYear.value = controller.financialYears
        .firstWhereOrNull(
          (f) => f.financial_year_id == widget.task.financialYearId,
        );

    // Set months
    controller.selectedFromMonth.value = widget.task.monthFrom;
    controller.selectedToMonth.value = widget.task.monthTo;

    // Set task instructions
    controller.taskInstructions.value = widget.task.instructions ?? '';

    // Set dates
    if (widget.task.allottedDate != null) {
      controller.allottedDate.value = widget.task.allottedDate!;
    }

    if (widget.task.expectedEndDate != null) {
      controller.expectedEndDate.value = widget.task.expectedEndDate!;
    }

    // Set priority
    controller.priority.value = priorityToString(widget.task.priority);

    // Set admin verification
    controller.adminVerification.value = widget.task.verifyByAdmin == '1';
  }

  Future<void> _updateTask() async {
    // Validate form fields before submission
    if (!_validateForm()) return;

    // Show loading state
    setState(() {
      isLoading = true;
    });

    try {
      // Check network connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => _updateTask());
        AppLoaders.customToast(
          message: 'Offline. Will retry when back online.',
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Collect form data from controller (similar to submitNewTask)
      final Map<String, dynamic> payload = _collectFormData();

      // Add the task ID from the original task
      payload['id'] = widget.task.srNo;

      // Format dates as needed
      payload['alloted_date'] = _formatDate(controller.allottedDate.value);
      payload['expected_end_date'] = _formatDate(
        controller.expectedEndDate.value,
      );

      // Log request for debugging
      print('[API REQUEST] edit_task_creation payload: ${jsonEncode(payload)}');

      // Make API request
      final data = await AppHttpHelper().sendMultipartRequest(
        'edit_task_creation',
        method: 'POST',
        fields: {'data': jsonEncode(payload)},
      );

      // Log response for debugging
      print('[API RESPONSE] edit_task_creation: $data');

      if (data['success'] == true) {
        // On success: Close modal and update task list
        if (mounted) {
          Navigator.pop(context);
        } // Close the modal sheet

        // Show success message
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['message'] ?? 'Task updated successfully',
        );

        // Refresh task list if TaskListController is available
        if (Get.isRegistered<TaskListController>()) {
          final taskListController = Get.find<TaskListController>();
          taskListController.fetchTasks(); // Refresh task list
        }
      } else {
        // On failure: Show error message but keep modal open
        AppLoaders.errorSnackBar(
          title: 'Error',
          message: data['message'] ?? 'Failed to update task',
        );
      }
    } catch (e) {
      // Handle exceptions
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      // Reset loading state if still mounted
      if (_isMounted && !_cancelRequests) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Format date for API
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Validate form fields
  bool _validateForm() {
    if (controller.selectedClient.value == null ||
        controller.selectedTask.value == null ||
        controller.selectedSubTask.value == null ||
        controller.selectedStaff.value == null ||
        controller.selectedFinancialYear.value == null ||
        controller.selectedFromMonth.value == null ||
        controller.selectedToMonth.value == null ||
        controller.taskInstructions.value.trim().isEmpty) {
      AppLoaders.warningSnackBar(
        title: 'Missing Fields',
        message: 'Please fill all required fields.',
      );
      return false;
    }
    return true;
  }

  // Collect form data into a map for API
  Map<String, dynamic> _collectFormData() {
    return {
      'client_id': controller.selectedClient.value?.clientId,
      'task_id': controller.selectedTask.value?.taskId,
      'sub_task_id': controller.selectedSubTask.value?.id,
      'alloted_to': controller.selectedStaff.value?.staffId,
      'alloted_by': controller.userId.value,
      'financial_year_id':
          controller.selectedFinancialYear.value?.financial_year_id,
      'month_from': controller.selectedFromMonth.value,
      'month_to': controller.selectedToMonth.value,
      'instruction': controller.taskInstructions.value,
      'alloted_date': controller.allottedDate.value.toIso8601String(),
      'expected_end_date': controller.expectedEndDate.value.toIso8601String(),
      'priority': controller.priority.value,
      'verify_by_admin': controller.adminVerification.value ? '1' : '0',
    };
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return Container(
      height: mediaQuery.size.height * 0.9,
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Edit Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          (isLoading)
              ? Expanded(child: AppLoaderAnimation())
              : Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Import the NewTaskMobileScreen content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Task and Subtask Selection
                              controller.tasks.isEmpty
                                  ? SizedBox(
                                    height: 80,
                                    child: _sectionLoadingPlaceholder(),
                                  )
                                  : TaskSelectionSection(
                                    controller: controller,
                                  ),

                              // Client Selection
                              controller.clients.isEmpty
                                  ? SizedBox(
                                    height: 80,
                                    child: _sectionLoadingPlaceholder(),
                                  )
                                  : ClientSelectionSection(
                                    controller: controller,
                                  ),

                              // Staff Allotment
                              controller.staffList.isEmpty
                                  ? SizedBox(
                                    height: 80,
                                    child: _sectionLoadingPlaceholder(),
                                  )
                                  : StaffAllotmentSection(
                                    controller: controller,
                                  ),

                              // Financial Year Selection
                              controller.financialYears.isEmpty
                                  ? SizedBox(
                                    height: 80,
                                    child: _sectionLoadingPlaceholder(),
                                  )
                                  : FinancialYearSection(
                                    controller: controller,
                                  ),

                              // Task Details Section
                              TaskDetailsSection(controller: controller),

                              // Update Button
                              SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: Obx(
                                  () =>
                                      controller.isSubmitting.value
                                          ? AppShimmerEffect(
                                            height: 56,
                                            width: double.infinity,
                                            radius: 12,
                                          )
                                          : ElevatedButton.icon(
                                            onPressed: _updateTask,
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                            ),
                                            label: Text(
                                              'Update Task',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 2,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // Section placeholder while data is loading
  Widget _sectionLoadingPlaceholder() {
    return AppShimmerEffect(height: 60, width: double.infinity, radius: 8);
  }
}
