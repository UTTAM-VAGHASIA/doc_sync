// lib/modal/operations/admin_verification_task_modal.dart (Updated Path)
// Or adjust to your actual model file path

import 'package:flutter/material.dart'; // Needed for Color type
import 'package:intl/intl.dart'; // For DateFormat

// --- Define Enums ---
// Added 'allotted' and 'verified' based on potential JSON values.
// Review these against ALL possible statuses from your API.
enum TaskStatus {
  completed,
  pending,
  awaiting,
  allotted,
  alloted,
  verified,
  client_waiting,
  re_alloted,
  unknown,
}

enum TaskPriority { high, medium, low, unknown }
// --------------------

class VerificationTask {
  // Existing & Renamed/Mapped Fields
  final String id; // from json['id']
  String srNo; // Not from JSON - likely assigned later for UI sequence
  final String fileNo; // from json['file_no']
  final String client; // from json['client_name']
  final String taskSubTask; // Constructed from task_name and sub_task_name
  final String allottedBy; // from json['alloted_by_name']
  final String allottedTo; // from json['alloted_to_name']
  final String instruction; // from json['instruction']
  final String endDate; // from json['expected_end_date'] (formatted)
  final TaskStatus status; // Parsed from json['status']
  final TaskPriority priority; // Parsed from json['priority']
  final bool approvalNeeded; // Parsed from json['verify_by_admin']
  bool isSelected; // UI state, not from JSON

  // --- New Fields from JSON ---
  final String clientId; // from json['client_id']
  final String taskId; // from json['task_id']
  final String subTaskId; // from json['sub_task_id']
  final String allottedToId; // from json['alloted_to']
  final String allottedById; // from json['alloted_by']
  final String financialYearId; // from json['financial_year_id']
  final String? monthFrom; // from json['month_from'] (nullable)
  final String? monthTo; // from json['month_to'] (nullable)
  final String allottedDate; // from json['alloted_date'] (formatted)
  final String? dateTime; // from json['date_time'] (nullable timestamp)
  final String taskName; // from json['task_name']
  final String subTaskName; // from json['sub_task_name']
  final String financialYear; // from json['financial_year']
  // final String adtDisplayDate; // from json['adt'] - Parsed 'alloted_date' is likely sufficient

  // --- Original 'period' field - Decide if you still need it ---
  // If 'period' was just derived from monthFrom/To/Year, you might not need it.
  // If it represented something else, keep it and map it from JSON if available.
  // final String period;

  VerificationTask({
    // Existing (some might be derived now)
    required this.id,
    this.srNo = '', // Default srNo, assign later if needed for UI sequence
    required this.fileNo,
    required this.client,
    required this.taskSubTask, // Now constructed in fromJson
    required this.allottedBy,
    required this.allottedTo,
    required this.instruction,
    required this.endDate,
    // Removed 'period' from constructor, derive if needed
    required this.status,
    required this.priority,
    required this.approvalNeeded,
    this.isSelected = false,
    // New
    required this.clientId,
    required this.taskId,
    required this.subTaskId,
    required this.allottedToId,
    required this.allottedById,
    required this.financialYearId,
    this.monthFrom,
    this.monthTo,
    required this.allottedDate,
    this.dateTime,
    required this.taskName,
    required this.subTaskName,
    required this.financialYear,
  });

  // Factory constructor to create a VerificationTask from JSON
  factory VerificationTask.fromJson(Map<String, dynamic> json) {
    // Handle potential nulls from JSON gracefully
    String taskNameFromJson = json['task_name']?.toString() ?? 'Unknown Task';
    String subTaskNameFromJson = json['sub_task_name']?.toString() ?? '';
    String combinedTaskSubTask =
        subTaskNameFromJson.isNotEmpty
            ? '$taskNameFromJson -- $subTaskNameFromJson'
            : taskNameFromJson;

    return VerificationTask(
      // Existing/Mapped
      id:
          json['id']?.toString() ??
          'N/A_${DateTime.now().millisecondsSinceEpoch}', // Generate temp ID if null
      fileNo: json['file_no']?.toString() ?? '-',
      client: json['client_name']?.toString() ?? 'Unknown Client',
      taskSubTask: combinedTaskSubTask,
      allottedBy: json['alloted_by_name']?.toString() ?? 'Unknown',
      allottedTo: json['alloted_to_name']?.toString() ?? 'Unknown',
      instruction: json['instruction']?.toString() ?? '',
      endDate: _formatDate(json['expected_end_date']?.toString()) ?? '-',
      status: _parseStatus(json['status']?.toString()),
      priority: _parsePriority(json['priority']?.toString()),
      approvalNeeded: json['verify_by_admin']?.toString() == '1',
      isSelected: false, // Default state
      // New Fields
      clientId: json['client_id']?.toString() ?? '-',
      taskId: json['task_id']?.toString() ?? '-',
      subTaskId: json['sub_task_id']?.toString() ?? '-',
      allottedToId: json['alloted_to']?.toString() ?? '-',
      allottedById: json['alloted_by']?.toString() ?? '-',
      financialYearId: json['financial_year_id']?.toString() ?? '-',
      monthFrom:
          json['month_from']?.toString(), // Keep as potentially null string
      monthTo: json['month_to']?.toString(), // Keep as potentially null string
      allottedDate: _formatDate(json['alloted_date']?.toString()) ?? '-',
      dateTime: json['date_time']?.toString(), // Keep timestamp string as is
      taskName: taskNameFromJson,
      subTaskName: subTaskNameFromJson,
      financialYear: json['financial_year']?.toString() ?? '-',
    );
  }

  // --- Helper Functions for Parsing (Static within the class) ---

  // Parses the status string from JSON into the TaskStatus enum
  static TaskStatus _parseStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'completed':
        return TaskStatus.completed;
      case 'pending':
        return TaskStatus.pending;
      case 'awaiting':
        return TaskStatus.awaiting;
      case 'allotted':
        return TaskStatus.allotted;
      case 'alloted':
        return TaskStatus.alloted;
      case 'verified':
        return TaskStatus.verified;
      case 'client_waiting':
        return TaskStatus.client_waiting;
      case 're_alloted':
        return TaskStatus.re_alloted;
      default:
        print(
          "Warning: Unknown TaskStatus string '$statusString', defaulting to unknown.",
        );
        return TaskStatus.unknown; // Use a specific unknown state
    }
  }

  // Parses the priority string from JSON into the TaskPriority enum
  static TaskPriority _parsePriority(String? priorityString) {
    switch (priorityString?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
        return TaskPriority.low;
      default:
        print(
          "Warning: Unknown TaskPriority string '$priorityString', defaulting to unknown.",
        );
        return TaskPriority.unknown; // Use a specific unknown state
    }
  }

  // Helper to format date strings (handles potential nulls and parsing errors)
  // Assumes input format is 'yyyy-MM-dd' from JSON
  static String? _formatDate(
    String? dateString, {
    String outputFormat = 'dd-MM-yyyy',
  }) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    try {
      // Try parsing common date formats, be more robust if needed
      DateTime dateTime;
      if (dateString.contains(' ')) {
        // Handle 'yyyy-MM-dd HH:mm:ss' if present
        dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(dateString);
      } else {
        dateTime = DateFormat('yyyy-MM-dd').parseStrict(dateString);
      }
      return DateFormat(outputFormat).format(dateTime);
    } catch (e) {
      print("Error formatting date '$dateString' with input 'yyyy-MM-dd': $e");
      // Optionally, try other input formats if necessary
      // try {
      //   DateTime dateTime = DateFormat('dd-MM-yyyy').parseStrict(dateString);
      //   return DateFormat(outputFormat).format(dateTime);
      // } catch (e2) {
      //    print("Error formatting date '$dateString' with input 'dd-MM-yyyy': $e2");
      //    return dateString; // Return original string if all formatting fails
      // }
      return dateString; // Return original if parsing fails
    }
  }
}

// --- Helper Functions for UI Display (Keep these outside the class) ---
// --- Update these to handle the new 'unknown' enum values ---

String statusVerificationToString(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
      return 'Completed';
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.awaiting:
      return 'Awaiting';
    case TaskStatus.allotted:
      return 'Allotted';
    case TaskStatus.alloted:
      return 'Alloted';
    case TaskStatus.verified:
      return 'Verified';
    case TaskStatus.client_waiting:
      return 'client_waiting';
    case TaskStatus.re_alloted:
      return 're_alloted';
    case TaskStatus.unknown:
      return 'Unknown'; // Handle unknown case
  }
}

String priorityVerificationToString(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'High';
    case TaskPriority.medium:
      return 'Medium';
    case TaskPriority.low:
      return 'Low';
    case TaskPriority.unknown:
      return 'Unknown'; // Handle unknown case
  }
}

// Example color functions - Add colors for new statuses
Color statusVerificationColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.completed:
      return Colors.green.shade600;
    case TaskStatus.pending:
      return Colors.orange.shade700;
    case TaskStatus.awaiting:
      return Colors.blue.shade600;
    case TaskStatus.allotted || TaskStatus.alloted:
      return Colors.purple.shade400;
    case TaskStatus.verified:
      return Colors.cyan.shade600;
    case TaskStatus.client_waiting:
      return Colors.red;
    case TaskStatus.re_alloted:
      return Colors.red;
    case TaskStatus.unknown:
      return Colors.grey.shade500; // Color for unknown
  }
}

Color priorityVerificationColor(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return Colors.red.shade600;
    case TaskPriority.medium:
      return Colors.amber.shade800;
    case TaskPriority.low:
      return Colors.blueGrey.shade400;
    case TaskPriority.unknown:
      return Colors.grey.shade500; // Color for unknown
  }
}

// -------------------------------------------------------------------
