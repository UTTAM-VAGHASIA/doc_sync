import 'package:doc_sync/features/authentication/controllers/user_controller.dart';
import 'package:doc_sync/features/operations/models/client_model.dart';
import 'package:doc_sync/features/operations/models/financial_year.dart';
import 'package:doc_sync/features/operations/models/staff_model.dart';
import 'package:doc_sync/features/operations/models/sub_task_model.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';
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
import 'package:intl/intl.dart';

class NewTaskController extends GetxController {
  // Global refreshing indicator
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // Current User Info (this will be fetched from Auth service in later tasks)
  RxString userId = ''.obs;
  RxString userName = ''.obs;
  RxString userRole = ''.obs;
  
  // Loading States
  final RxBool isLoadingTasks = false.obs;
  final RxBool isLoadingSubTasks = false.obs;
  final RxBool isLoadingStaff = false.obs;
  final RxBool isLoadingClients = false.obs;
  final RxBool isLoadingFinancialYears = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isDraftLoading = false.obs;
  final RxBool isDraftSaving = false.obs;
  final RxBool isDraftClearing = false.obs;

  // Data Lists
  final RxList<Task> tasks = <Task>[].obs;
  final RxList<SubTask> subTasks = <SubTask>[].obs;
  final RxList<Staff> staffList = <Staff>[].obs;
  final RxList<Client> clients = <Client>[].obs;
  final RxList<FinancialYear> financialYears = <FinancialYear>[].obs;
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // Selected Values
  final Rx<Task?> selectedTask = Rx<Task?>(null);
  final Rx<SubTask?> selectedSubTask = Rx<SubTask?>(null);
  final Rx<Staff?> selectedStaff = Rx<Staff?>(null);
  final Rx<Client?> selectedClient = Rx<Client?>(null);
  final Rx<FinancialYear?> selectedFinancialYear = Rx<FinancialYear?>(null);
  final Rx<String?> selectedFromMonth = Rx<String?>(null);
  final Rx<String?> selectedToMonth = Rx<String?>(null);

  // Form Values
  final RxString taskInstructions = ''.obs;
  final Rx<DateTime> allottedDate = DateTime.now().obs;
  final Rx<DateTime> expectedEndDate = DateTime.now().obs;
  final RxString priority = 'Medium'.obs; // Default priority
  final RxBool adminVerification = false.obs;

  // Form Key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Track whether task instruction is being edited by user
  final RxBool isTaskInstructionsBeingEdited = false.obs;

  // Flag to prevent recursive updates when updating the text field
  final RxBool isUpdatingInstructions = false.obs;

  // Store user-entered instruction content
  final RxString userEnteredInstructions = ''.obs;

  // Track cursor position
  final Rx<TextSelection> cursorPosition = Rx<TextSelection>(
    const TextSelection.collapsed(offset: 0),
  );

  // Sections that should be auto-generated
  final List<String> instructionSections = [
    'Task:',
    'Subtask:',
    'Period:',
    'Month From:',
    'Month To:',
  ];

  // Special handling for loading draft or initial setup to ensure task instructions are updated
  void updateInstructionsAfterLoad() {
    // Wait briefly to ensure all values are loaded
    Future.delayed(Duration(milliseconds: 100), () {
      updateTaskInstructions();
    });
  }

  @override
  Future<void> onInit() async {
    print('onInit');
    userId.value = UserController.instance.user.value.id ?? '';
    userName.value = UserController.instance.user.value.name ?? 'Unable to load User';
    userRole.value = UserController.instance.user.value.type!.name;
    print(userId);
    print(userName);
    print(userRole);
    super.onInit();
    fetchTasks();
    fetchClients();
    fetchStaff();
    fetchFinancialYears();
    setupTaskInstructionListeners();
    ever(selectedTask, (task) {
      if (task != null) {
        fetchSubTasksForTask(task.taskId);
      } else {
        subTasks.clear();
      }
    });
    updateInstructionsAfterLoad();
  }

  // --- API Integration ---

  Future<void> fetchTasks() async {
    isLoadingTasks.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchTasks);
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "get_task_list",
        method: "GET",
      );
      if (data['success']) {
        tasks.value =
            (data['data'] as List)
                .map((json) => Task.fromJson(json, true))
                .toList();
      } else {
        AppLoaders.errorSnackBar(title: "Error", message: data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: "Error", message: e.toString());
    } finally {
      isLoadingTasks.value = false;
    }
  }

  Future<void> fetchClients() async {
    isLoadingClients.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchClients);
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "get_client_list",
        method: "GET",
      );
      if (data['success']) {
        clients.value =
            (data['data'] as List)
                .map((json) => Client.fromJson(json))
                .toList();
      } else {
        AppLoaders.errorSnackBar(title: "Error", message: data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: "Error", message: e.toString());
    } finally {
      isLoadingClients.value = false;
    }
  }

  Future<void> fetchStaff() async {
    isLoadingStaff.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchStaff);
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "get_staff_list",
        method: "GET",
      );
      if (data['success']) {
        staffList.value =
            (data['data'] as List)
                .map((json) => Staff.fromJson(json ?? {}))
                .where((staff) => staff.staffId.isNotEmpty)
                .toList();
      } else {
        AppLoaders.errorSnackBar(title: "Error", message: data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: "Error", message: e.toString());
    } finally {
      isLoadingStaff.value = false;
    }
  }

  Future<void> fetchFinancialYears() async {
    isLoadingFinancialYears.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(fetchFinancialYears);
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "get_financial_year_list",
        method: "GET",
      );
      if (data['success']) {
        financialYears.value =
            (data['data'] as List)
                .map((json) => FinancialYear.fromJson(json))
                .toList();
      } else {
        AppLoaders.errorSnackBar(title: "Error", message: data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: "Error", message: e.toString());
    } finally {
      isLoadingFinancialYears.value = false;
    }
  }

  Future<void> fetchSubTasksForTask(String taskId) async {
    isLoadingSubTasks.value = true;
    subTasks.clear();
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => fetchSubTasksForTask(taskId));
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "get_sub_task_list",
        method: "POST",
        fields: {
          'data': jsonEncode({'id': taskId}),
        },
      );
      if (data['success']) {
        subTasks.value =
            (data['data'] as List)
                .map((json) => SubTask.fromJson(json))
                .toList();
      } else {
        AppLoaders.errorSnackBar(title: "Error", message: data['message']);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: "Error", message: e.toString());
    } finally {
      isLoadingSubTasks.value = false;
    }
  }

  // Reset all form fields
  void resetForm() {
    selectedTask.value = null;
    selectedSubTask.value = null;
    selectedStaff.value = null;
    selectedClient.value = null;
    selectedFinancialYear.value = null;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    taskInstructions.value = '';
    allottedDate.value = DateTime.now();
    expectedEndDate.value = DateTime.now();
    priority.value = 'Medium';
    adminVerification.value = false;
  }

  // Form validation logic
  bool validateForm() {
    if (selectedTask.value == null) {
      AppLoaders.errorSnackBar(title: 'Error', message: 'Please select a task');
      return false;
    }

    if (selectedClient.value == null) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please select a client',
      );
      return false;
    }

    if (selectedStaff.value == null) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please select staff to allot the task',
      );
      return false;
    }

    if (selectedFinancialYear.value == null) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please select a financial year',
      );
      return false;
    }

    if (selectedFromMonth.value == null) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please select a from month',
      );
      return false;
    }

    if (selectedToMonth.value == null) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please select a to month',
      );
      return false;
    }

    // Validate that "To Month" comes after "From Month"
    if (months.indexOf(selectedFromMonth.value!) >
        months.indexOf(selectedToMonth.value!)) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'To month must come after from month',
      );
      return false;
    }

    if (taskInstructions.value.isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please enter task instructions',
      );
      return false;
    }

    // Validate that Expected End Date is on or after Allotted Date
    if (expectedEndDate.value.isBefore(allottedDate.value) &&
        !_isSameDay(expectedEndDate.value, allottedDate.value)) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Expected end date must be on or after allotted date',
      );
      return false;
    }

    return true;
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Method to save the current form state as a draft
  Future<void> saveDraft() async {
    isDraftSaving.value = true;
    try {
      final draft = _collectFormData();
      await StorageUtility.instance().writeData(
        'new_task_draft',
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
      print(e.toString());
    } finally {
      isDraftSaving.value = false;
    }
  }

  // Method to load a previously saved draft
  Future<void> loadDraft() async {
    isDraftLoading.value = true;
    try {
      final jsonData = await StorageUtility.instance().readData(
        'new_task_draft',
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
    selectedTask.value = null;
    selectedSubTask.value = null;
    selectedClient.value = null;
    selectedStaff.value = null;
    selectedFinancialYear.value = null;
    selectedFromMonth.value = null;
    selectedToMonth.value = null;
    taskInstructions.value = '';
    allottedDate.value = DateTime.now();
    expectedEndDate.value = DateTime.now();
    priority.value = 'Medium';
    adminVerification.value = false;

    AppLoaders.successSnackBar(title: 'Success', message: 'Form cleared');
  }

  // Format the instruction text based on selected fields
  void updateTaskInstructions() {
    // Skip if currently updating to prevent recursive calls
    if (isUpdatingInstructions.value) return;

    isUpdatingInstructions.value = true;

    try {
      // Parse the current text to identify formatted sections and custom text
      Map<String, dynamic> parsedContent = parseInstructionContent(
        taskInstructions.value,
      );

      // Update the formatted sections with current values
      parsedContent = updateFormattedSections(parsedContent);

      // Reconstruct the instruction text maintaining custom text placement
      taskInstructions.value = reconstructInstructionText(parsedContent);
    } finally {
      isUpdatingInstructions.value = false;
    }
  }

  // Parse the instruction text into formatted sections and custom text
  Map<String, dynamic> parseInstructionContent(String text) {
    if (text.isEmpty) {
      return {
        'sections': <String, String>{},
        'customTexts': <Map<String, dynamic>>[],
      };
    }

    // Map to store formatted sections and their values
    Map<String, String> sections = <String, String>{};

    // List to store custom text blocks with their positions
    List<Map<String, dynamic>> customTexts = <Map<String, dynamic>>[];

    // Split text by lines
    List<String> lines = text.split('\n');
    String currentCustomText = '';
    int currentPosition = -1; // Position relative to formatted sections

    // Track which sections we've seen
    Map<String, bool> sectionSeen = <String, bool>{};
    for (var section in instructionSections) {
      sectionSeen[section] = false;
    }

    // Count how many formatted sections we've seen
    int formattedSectionsSeen = 0;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      bool isFormatLine = false;

      // Check if this line is a formatted section
      for (String section in instructionSections) {
        if (line.startsWith('$section ')) {
          // If we have accumulated custom text, save it with its position
          if (currentCustomText.isNotEmpty) {
            customTexts.add(<String, dynamic>{
              'text': currentCustomText,
              'position': currentPosition,
            });
            currentCustomText = '';
          }

          // Record this formatted section
          sections[section] = line.substring(section.length + 1).trim();
          sectionSeen[section] = true;
          isFormatLine = true;
          formattedSectionsSeen++;
          currentPosition = formattedSectionsSeen;
          break;
        }
      }

      // If not a format line, add to current custom text
      if (!isFormatLine) {
        if (currentCustomText.isNotEmpty) {
          currentCustomText += '\n';
        }
        currentCustomText += line;
      }
    }

    // Don't forget any trailing custom text
    if (currentCustomText.isNotEmpty) {
      customTexts.add(<String, dynamic>{
        'text': currentCustomText,
        'position': currentPosition,
      });
    }

    return {'sections': sections, 'customTexts': customTexts};
  }

  // Update formatted sections with current selection values
  Map<String, dynamic> updateFormattedSections(
    Map<String, dynamic> parsedContent,
  ) {
    Map<String, String> sections = Map<String, String>.from(
      parsedContent['sections'] ?? {},
    );
    List<Map<String, dynamic>> customTexts = List<Map<String, dynamic>>.from(
      (parsedContent['customTexts'] ?? []).map(
        (item) =>
            item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{
                  'text': item?.toString() ?? '',
                  'position': -1,
                },
      ),
    );

    // Update Task section
    if (selectedTask.value != null) {
      sections['Task:'] = selectedTask.value!.taskName;
    } else {
      sections.remove('Task:');
    }

    // Update Subtask section
    if (selectedSubTask.value != null) {
      sections['Subtask:'] = selectedSubTask.value!.subTaskName;
    } else {
      sections.remove('Subtask:');
    }

    // Update Period section
    if (selectedFinancialYear.value != null) {
      sections['Period:'] = selectedFinancialYear.value!.financial_year;
    } else {
      sections.remove('Period:');
    }

    // Update Month From section
    if (selectedFromMonth.value != null) {
      sections['Month From:'] = selectedFromMonth.value!;
    } else {
      sections.remove('Month From:');
    }

    // Update Month To section
    if (selectedToMonth.value != null) {
      sections['Month To:'] = selectedToMonth.value!;
    } else {
      sections.remove('Month To:');
    }

    return {'sections': sections, 'customTexts': customTexts};
  }

  // Reconstruct the instruction text maintaining custom text placement
  String reconstructInstructionText(Map<String, dynamic> parsedContent) {
    Map<String, String> sections = Map<String, String>.from(
      parsedContent['sections'] ?? {},
    );
    // Fix for type 'List<dynamic>' is not a subtype of type 'List<Map<String, dynamic>>'
    List<dynamic> rawCustomTexts = parsedContent['customTexts'] ?? [];

    // Create the complete ordered list of sections
    List<String> orderedLines = [];

    // Add formatted sections in their defined order
    int sectionCount = 0;
    for (String section in instructionSections) {
      if (sections.containsKey(section)) {
        orderedLines.add('$section ${sections[section]}');
        sectionCount++;

        // Add any custom text that belongs after this section
        for (var customText in rawCustomTexts) {
          // Safe access using dynamic type
          if (customText is Map && customText['position'] == sectionCount) {
            orderedLines.add(customText['text']?.toString() ?? '');
          }
        }
      }
    }

    // Add any custom text that should be at the end
    for (var customText in rawCustomTexts) {
      if (customText is Map &&
          (customText['position'] == null ||
              customText['position'] > sectionCount ||
              customText['position'] == -1)) {
        if (orderedLines.isNotEmpty) {
          orderedLines.add(customText['text']?.toString() ?? '');
        } else if (customText['text'] != null) {
          // If no formatted sections, just use the custom text
          return customText['text'].toString();
        }
      }
    }

    return orderedLines.join('\n');
  }

  // Extract user's custom text that doesn't match our format sections (legacy method kept for reference)
  String extractCustomText(String currentText) {
    if (currentText.isEmpty) return '';

    // Split by lines and process
    List<String> lines = currentText.split('\n');
    List<String> customLines = [];

    // Keep track of which format sections we've found
    Map<String, bool> formatSectionFound = {};
    for (String section in instructionSections) {
      formatSectionFound[section] = false;
    }

    // Process each line
    for (String line in lines) {
      bool isFormatLine = false;

      // Check if line matches any of our format sections
      for (String section in instructionSections) {
        if (line.startsWith('$section ')) {
          formatSectionFound[section] = true;
          isFormatLine = true;
          break;
        }
      }

      // If not a format line, it's custom text
      if (!isFormatLine) {
        customLines.add(line);
      }
    }

    return customLines.join('\n');
  }

  // Generate the formatted instruction text based on currently selected fields (legacy method kept for reference)
  String generateFormattedInstructions() {
    List<String> formattedLines = [];

    // Task
    if (selectedTask.value != null) {
      formattedLines.add('Task: ${selectedTask.value!.taskName}');
    }

    // Subtask
    if (selectedSubTask.value != null) {
      formattedLines.add('Subtask: ${selectedSubTask.value!.subTaskName}');
    }

    // Financial Year (Period)
    if (selectedFinancialYear.value != null) {
      formattedLines.add(
        'Period: ${selectedFinancialYear.value!.financial_year}',
      );
    }

    // Month From
    if (selectedFromMonth.value != null) {
      formattedLines.add('Month From: ${selectedFromMonth.value}');
    }

    // Month To
    if (selectedToMonth.value != null) {
      formattedLines.add('Month To: ${selectedToMonth.value}');
    }

    return formattedLines.join('\n');
  }

  // Method to add listeners for updating task instructions
  void setupTaskInstructionListeners() {
    // React to changes in selected fields
    ever(selectedTask, (_) => updateTaskInstructions());
    ever(selectedSubTask, (_) => updateTaskInstructions());
    ever(selectedFinancialYear, (_) => updateTaskInstructions());
    ever(selectedFromMonth, (_) => updateTaskInstructions());
    ever(selectedToMonth, (_) => updateTaskInstructions());
  }

  /// Loads all dropdown data in parallel and reloads subtasks if a task is selected.
  Future<void> loadData() async {
    await Future.wait([
      fetchTasks(),
      fetchClients(),
      fetchStaff(),
      fetchFinancialYears(),
    ]);
    // If a task is already selected, reload its subtasks
    if (selectedTask.value != null) {
      await fetchSubTasksForTask(selectedTask.value!.taskId);
    }
  }

  /// Adds a new task via API and reloads the task list, auto-selecting the new task.
  Future<void> addTask(String taskName) async {
    if (taskName.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Task name cannot be empty',
      );
      return;
    }
    isLoadingTasks.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => addTask(taskName));
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "add_task",
        method: "POST",
        fields: {
          'data': jsonEncode({'task_name': taskName}),
        },
      );
      if (data['success'] == true) {
        await fetchTasks();
        // Auto-select the new task by name
        final newTask = tasks.firstWhereOrNull((t) => t.taskName == taskName);
        if (newTask != null) {
          selectedTask.value = newTask;
        }
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['response'] ?? 'Task added successfully',
        );
      } else {
        AppLoaders.errorSnackBar(
          title: 'Error',
          message: data['response'] ?? data['message'] ?? 'Failed to add task',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingTasks.value = false;
    }
  }

  /// Adds a new sub-task via API and reloads the sub-task list, auto-selecting the new sub-task.
  Future<void> addSubTask(String subTaskName) async {
    if (subTaskName.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Sub-task name cannot be empty',
      );
      return;
    }
    if (selectedTask.value == null) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Please select a task first',
      );
      return;
    }
    isLoadingSubTasks.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => addSubTask(subTaskName));
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "add_sub_task",
        method: "POST",
        fields: {
          'data': jsonEncode({
            'task_id': selectedTask.value!.taskId,
            'sub_task_name': subTaskName,
          }),
        },
      );
      if (data['success'] == true) {
        await fetchSubTasksForTask(selectedTask.value!.taskId);
        // Auto-select the new sub-task by name
        final newSubTask = subTasks.firstWhereOrNull(
          (s) => s.subTaskName == subTaskName,
        );
        if (newSubTask != null) {
          selectedSubTask.value = newSubTask;
        }
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['response'] ?? 'Sub-task added successfully',
        );
      } else {
        AppLoaders.errorSnackBar(
          title: 'Error',
          message:
              data['response'] ?? data['message'] ?? 'Failed to add sub-task',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingSubTasks.value = false;
    }
  }

  /// Adds a new staff member via API and reloads the staff list, auto-selecting the new staff.
  Future<void> addStaff({
    required String name,
    required String contact,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty ||
        contact.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'All fields are required',
      );
      return;
    }
    isLoadingStaff.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(
          () => addStaff(
            name: name,
            contact: contact,
            email: email,
            password: password,
          ),
        );
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "staff_registration",
        method: "POST",
        fields: {
          'data': jsonEncode({
            'name': name,
            'contact': contact,
            'email': email,
            'password': password,
            'type': 'staff',
          }),
        },
      );
      if (data['success'] == true) {
        await fetchStaff();
        // Auto-select the new staff by email if available, else by name
        Staff? newStaff;
        if (email.isNotEmpty) {
          newStaff = staffList.firstWhereOrNull((s) => s.email == email);
        }
        newStaff ??= staffList.firstWhereOrNull((s) => s.staffName == name);
        if (newStaff != null) {
          selectedStaff.value = newStaff;
        }
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['message'] ?? 'Staff added successfully',
        );
      } else {
        // Handle duplicate email error
        final errorMsg =
            data['error'] ?? data['message'] ?? 'Failed to add staff';
        AppLoaders.errorSnackBar(title: 'Error', message: errorMsg);
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingStaff.value = false;
    }
  }

  /// Adds a new financial year via API and reloads the financial year list, auto-selecting the new year.
  Future<void> addFinancialYear({
    required String startYear,
    required String endYear,
  }) async {
    final String yearString = '$startYear-$endYear';
    isLoadingFinancialYears.value = true;
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(
          () => addFinancialYear(startYear: startYear, endYear: endYear),
        );
        AppLoaders.customToast(
          message: "Offline. Will retry when back online.",
        );
        return;
      }
      final data = await AppHttpHelper().sendMultipartRequest(
        "financial_year_registration",
        method: "POST",
        fields: {
          'data': jsonEncode({'year': yearString, 'add_by': userName}),
        },
      );
      if (data['success'] == true) {
        await fetchFinancialYears();
        // Auto-select the new year by string match
        final newYear = financialYears.firstWhereOrNull(
          (y) => y.financial_year == yearString,
        );
        if (newYear != null) {
          selectedFinancialYear.value = newYear;
        }
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['message'] ?? 'Financial year added successfully',
        );
      } else {
        AppLoaders.errorSnackBar(
          title: 'Error',
          message: data['message'] ?? 'Failed to add financial year',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isLoadingFinancialYears.value = false;
    }
  }

  /// Collects all form data into a map for draft saving
  Map<String, dynamic> _collectFormData() {
    return {
      'client_id': selectedClient.value?.clientId,
      'task_id': selectedTask.value?.taskId,
      'sub_task_id': selectedSubTask.value?.id,
      'alloted_to': selectedStaff.value?.staffId,
      'alloted_by': userId.value, // Set this from user/session
      'financial_year_id': selectedFinancialYear.value?.financial_year_id,
      'month_from': selectedFromMonth.value,
      'month_to': selectedToMonth.value,
      'instruction': taskInstructions.value,
      'alloted_date': allottedDate.value.toIso8601String(),
      'expected_end_date': expectedEndDate.value.toIso8601String(),
      'priority': priority.value,
      'verify_by_admin': adminVerification.value ? 1 : 0,
      'sender_id': userId.value, // Set this from user/session
      'sender_type': userRole.value, // Set this from user/session
    };
  }

  /// Applies draft data to form fields
  Future<void> _applyFormData(Map<String, dynamic> draft) async {
    selectedTask.value = tasks.firstWhereOrNull(
      (t) => t.taskId == draft['task_id'],
    );
    await loadData();
    selectedClient.value = clients.firstWhereOrNull(
      (c) => c.clientId == draft['client_id'],
    );
    selectedSubTask.value = subTasks.firstWhereOrNull(
      (s) => s.id == draft['sub_task_id'],
    );
    selectedStaff.value = staffList.firstWhereOrNull(
      (s) => s.staffId == draft['alloted_to'],
    );
    selectedFinancialYear.value = financialYears.firstWhereOrNull(
      (f) => f.financial_year_id == draft['financial_year_id'],
    );
    selectedFromMonth.value = draft['month_from'];
    selectedToMonth.value = draft['month_to'];
    taskInstructions.value = draft['instruction'] ?? '';
    allottedDate.value = draft['alloted_date'] != null
      ? DateTime.parse(draft['alloted_date'])
      : DateTime.now();
  expectedEndDate.value = draft['expected_end_date'] != null
      ? DateTime.parse(draft['expected_end_date'])
      : DateTime.now();
    priority.value = draft['priority'];
    adminVerification.value = draft['verify_by_admin'] == 1;
    // sender_id, sender_type, alloted_by are set from session/user
  }

  /// Submits the new task form
  Future<void> submitNewTask() async {
    if (!_validateForm()) return;
    isSubmitting.value = true;
    await saveDraft();
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => submitNewTask());
        AppLoaders.customToast(
          message: 'Offline. Will retry when back online.',
        );
        return;
      }
      final Map<String, dynamic> payload = _collectFormData();
      // Format dates as needed (e.g., yyyy-MM-dd)
      payload['alloted_date'] = _formatDate(allottedDate.value);
      payload['expected_end_date'] = _formatDate(expectedEndDate.value);
      print(
        '[API REQUEST] add_new_taskcreation payload: ${jsonEncode(payload)}',
      );
      final data = await AppHttpHelper().sendMultipartRequest(
        'add_new_taskcreation',
        method: 'POST',
        fields: {'data': jsonEncode(payload)},
      );
      print('[API RESPONSE] add_new_taskcreation: $data');
      if (data['success'] == true) {
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['message'] ?? 'Task created successfully',
        );
        resetForm();
        // Do NOT clear the draft here; only clear on explicit user action
        _showPostSubmitDialog();
      } else {
        AppLoaders.errorSnackBar(
          title: 'Error',
          message: data['message'] ?? 'Failed to create task',
        );
      }
    } catch (e) {
      AppLoaders.errorSnackBar(title: 'Error', message: e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Validates the form fields before submission
  bool _validateForm() {
    if (selectedClient.value == null ||
        selectedTask.value == null ||
        selectedSubTask.value == null ||
        selectedStaff.value == null ||
        selectedFinancialYear.value == null ||
        selectedFromMonth.value == null ||
        selectedToMonth.value == null ||
        taskInstructions.value.trim().isEmpty) {
      AppLoaders.warningSnackBar(
        title: 'Missing Fields',
        message: 'Please fill all required fields.',
      );
      return false;
    }
    return true;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Shows a dialog after successful submission with improved UI
  void _showPostSubmitDialog() {
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
                'Task Created!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your task has been created successfully.\n\nWould you like to add another task or go to the task list?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Another'),
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
                      label: const Text('Go to Task List'),
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
                        Get.offAllNamed(AppRoutes.tasks);
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

  Future<void> clearDraft() async {
    isDraftClearing.value = true;
    try {
      await StorageUtility.instance().removeData('new_task_draft');
      AppLoaders.successSnackBar(
        title: 'Draft Cleared',
        message: 'Draft removed.',
      );
    } catch (e) {
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to clear draft.',
      );
    } finally {
      isDraftClearing.value = false;
    }
  }
}
