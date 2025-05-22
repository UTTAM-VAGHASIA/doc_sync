import 'package:flutter/material.dart'; // Needed for Color type
import 'package:intl/intl.dart';

enum AdminTaskStatus { allotted, completed, awaiting, reallotted }

enum AdminTaskPriority { high, medium, low }

class AdminVerificationTask {
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

  AdminVerificationTask({
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

  factory AdminVerificationTask.fromJson(Map<String, dynamic> json) {
    return AdminVerificationTask(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      taskId: json['task_id'] ?? '',
      subTaskId: json['sub_task_id'] ?? '',
      allottedTo: json['alloted_to'] ?? '',
      allottedBy: json['alloted_by'] ?? '',
      financialYearId: json['financial_year_id'] ?? '',
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

  AdminTaskStatus get taskStatus {
    switch (status.toLowerCase().trim()) {
      case 'allotted':
      case 'alloted':
        return AdminTaskStatus.allotted;
      case 'completed':
      case 'complete':
        return AdminTaskStatus.completed;
      case 'awaiting':
      case 'pending':
        return AdminTaskStatus.awaiting;
      case 're-allotted':
      case 'reallotted':
      case 're-alloted':
      case 'realloted':
        return AdminTaskStatus.reallotted;
      default:
        return AdminTaskStatus.awaiting;
    }
  }

  AdminTaskPriority get taskPriority {
    switch (priority.toLowerCase().trim()) {
      case 'high':
        return AdminTaskPriority.high;
      case 'medium':
        return AdminTaskPriority.medium;
      case 'low':
        return AdminTaskPriority.low;
      default:
        return AdminTaskPriority.medium;
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

String adminStatusToString(AdminTaskStatus status) {
  switch (status) {
    case AdminTaskStatus.allotted:
      return 'Allotted';
    case AdminTaskStatus.completed:
      return 'Completed';
    case AdminTaskStatus.awaiting:
      return 'Awaiting';
    case AdminTaskStatus.reallotted:
      return 'Re-allotted';
  }
}

Color adminStatusToColor(AdminTaskStatus status) {
  switch (status) {
    case AdminTaskStatus.allotted:
      return Colors.blue.shade700;
    case AdminTaskStatus.completed:
      return Colors.green.shade700;
    case AdminTaskStatus.awaiting:
      return Colors.orange.shade700;
    case AdminTaskStatus.reallotted:
      return Colors.red.shade700;
  }
}

String adminPriorityToString(AdminTaskPriority priority) {
  switch (priority) {
    case AdminTaskPriority.high:
      return 'High';
    case AdminTaskPriority.medium:
      return 'Medium';
    case AdminTaskPriority.low:
      return 'Low';
  }
}

Color adminPriorityToColor(AdminTaskPriority priority) {
  switch (priority) {
    case AdminTaskPriority.high:
      return Colors.red.shade600;
    case AdminTaskPriority.medium:
      return Colors.orange.shade600;
    case AdminTaskPriority.low:
      return Colors.green.shade600;
  }
}
