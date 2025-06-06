import 'package:flutter/material.dart';

enum TaskHistoryStatus { allotted, completed, pending, client_waiting, re_alloted }

enum TaskHistoryPriority { high, medium, low }

class TaskHistoryTask {
  final String id;
  final String clientId;
  final String taskId;
  final String subTaskId;
  final String allottedTo;
  final String allottedBy;
  final String financialYearId;
  final String monthFrom;
  final String monthTo;
  final String instruction;
  final String allottedDate;
  final String expectedEndDate;
  final String status;
  final String priority;
  final String verifyByAdmin;
  final String dateTime;
  final String taskName;
  final String subTaskName;
  final String allottedToName;
  final String allottedByName;
  final String adt;
  final String clientName;
  final String fileNo;
  final String financialYear;

  TaskHistoryTask({
    required this.id,
    required this.clientId,
    required this.taskId,
    required this.subTaskId,
    required this.allottedTo,
    required this.allottedBy,
    required this.financialYearId,
    required this.monthFrom,
    required this.monthTo,
    required this.instruction,
    required this.allottedDate,
    required this.expectedEndDate,
    required this.status,
    required this.priority,
    required this.verifyByAdmin,
    required this.dateTime,
    required this.taskName,
    required this.subTaskName,
    required this.allottedToName,
    required this.allottedByName,
    required this.adt,
    required this.clientName,
    required this.fileNo,
    required this.financialYear,
  });

  factory TaskHistoryTask.fromJson(Map<String, dynamic> json) {
    return TaskHistoryTask(
      id: json['id']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      taskId: json['task_id']?.toString() ?? '',
      subTaskId: json['sub_task_id']?.toString() ?? '',
      allottedTo: json['alloted_to']?.toString() ?? '',
      allottedBy: json['alloted_by']?.toString() ?? '',
      financialYearId: json['financial_year_id']?.toString() ?? '',
      monthFrom: json['month_from'] ?? '',
      monthTo: json['month_to'] ?? '',
      instruction: json['instruction'] ?? '',
      allottedDate: json['alloted_date'] ?? '',
      expectedEndDate: json['expected_end_date'] ?? '',
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      verifyByAdmin: json['verify_by_admin'] ?? '',
      dateTime: json['date_time'] ?? '',
      taskName: json['task_name'] ?? '',
      subTaskName: json['sub_task_name'] ?? '',
      allottedToName: json['alloted_to_name'] ?? '',
      allottedByName: json['alloted_by_name'] ?? '',
      adt: json['adt'] ?? '',
      clientName: json['client_name'] ?? '',
      fileNo: json['file_no'] ?? '',
      financialYear: json['financial_year'] ?? '',
    );
  }

  TaskHistoryStatus get taskStatus {
    switch (status.toLowerCase().trim()) {
      case 'allotted':
      case 'alloted':
        return TaskHistoryStatus.allotted;
      case 'completed':
      case 'complete':
        return TaskHistoryStatus.completed;
      case 'client_waiting':
        return TaskHistoryStatus.client_waiting;
      case 're-allotted':
      case 'reallotted':
      case 're-alloted':
      case 'realloted':
      case 're_alloted':
      case 're_allotted':
        return TaskHistoryStatus.re_alloted;
      default:
        return TaskHistoryStatus.pending;
    }
  }

  TaskHistoryPriority get taskPriority {
    switch (priority.toLowerCase().trim()) {
      case 'high':
        return TaskHistoryPriority.high;
      case 'medium':
        return TaskHistoryPriority.medium;
      case 'low':
        return TaskHistoryPriority.low;
      default:
        return TaskHistoryPriority.medium;
    }
  }

  String get period {
    if (monthFrom.isNotEmpty && monthTo.isNotEmpty) {
      return '$monthFrom - $monthTo';
    } else if (monthFrom.isNotEmpty) {
      return monthFrom;
    } else if (monthTo.isNotEmpty) {
      return monthTo;
    }
    return 'N/A';
  }
}

String taskHistoryStatusToString(TaskHistoryStatus status) {
  switch (status) {
    case TaskHistoryStatus.allotted:
      return 'Allotted';
    case TaskHistoryStatus.completed:
      return 'Completed';
    case TaskHistoryStatus.client_waiting:
      return 'Client Waiting';
    case TaskHistoryStatus.re_alloted:
      return 'Re-allotted';
    case TaskHistoryStatus.pending:
      return 'Pending';
  }
}

Color taskHistoryStatusToColor(TaskHistoryStatus status) {
  switch (status) {
    case TaskHistoryStatus.allotted:
      return Colors.blue.shade700;
    case TaskHistoryStatus.completed:
      return Colors.green.shade700;
    case TaskHistoryStatus.client_waiting:
      return Colors.orange.shade700;
    case TaskHistoryStatus.re_alloted:
      return Colors.red.shade700;
    case TaskHistoryStatus.pending:
      return Colors.amber.shade700;
  }
}

String taskHistoryPriorityToString(TaskHistoryPriority priority) {
  switch (priority) {
    case TaskHistoryPriority.high:
      return 'High';
    case TaskHistoryPriority.medium:
      return 'Medium';
    case TaskHistoryPriority.low:
      return 'Low';
  }
}

Color taskHistoryPriorityToColor(TaskHistoryPriority priority) {
  switch (priority) {
    case TaskHistoryPriority.high:
      return Colors.red.shade600;
    case TaskHistoryPriority.medium:
      return Colors.orange.shade600;
    case TaskHistoryPriority.low:
      return Colors.green.shade600;
  }
} 