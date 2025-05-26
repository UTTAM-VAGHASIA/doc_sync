import 'package:doc_sync/features/operations/models/client_model.dart';
import 'package:doc_sync/features/operations/models/financial_year.dart';
import 'package:doc_sync/features/operations/models/staff_model.dart';
import 'package:doc_sync/features/operations/models/sub_task_model.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';

/// A model class specifically designed for the new task form.
/// Provides full JSON serialization support for form persistence.
class NewTaskFormModel {
  // Task selection
  final Task? task;
  final SubTask? subTask;

  // Client selection
  final Client? client;

  // Staff selection
  final Staff? staff;

  // Financial year and period
  final FinancialYear? financialYear;
  final String? fromMonth;
  final String? toMonth;

  // Task details
  final String instructions;
  final DateTime? allottedDate;
  final DateTime? expectedEndDate;
  final String priority;
  final bool adminVerification;

  NewTaskFormModel({
    this.task,
    this.subTask,
    this.client,
    this.staff,
    this.financialYear,
    this.fromMonth,
    this.toMonth,
    this.instructions = '',
    this.allottedDate,
    this.expectedEndDate,
    this.priority = 'Medium',
    this.adminVerification = false,
  });

  // Create a copy of this model with modified fields
  NewTaskFormModel copyWith({
    Task? task,
    SubTask? subTask,
    Client? client,
    Staff? staff,
    FinancialYear? financialYear,
    String? fromMonth,
    String? toMonth,
    String? instructions,
    DateTime? allottedDate,
    DateTime? expectedEndDate,
    String? priority,
    bool? adminVerification,
  }) {
    return NewTaskFormModel(
      task: task ?? this.task,
      subTask: subTask ?? this.subTask,
      client: client ?? this.client,
      staff: staff ?? this.staff,
      financialYear: financialYear ?? this.financialYear,
      fromMonth: fromMonth ?? this.fromMonth,
      toMonth: toMonth ?? this.toMonth,
      instructions: instructions ?? this.instructions,
      allottedDate: allottedDate ?? this.allottedDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      priority: priority ?? this.priority,
      adminVerification: adminVerification ?? this.adminVerification,
    );
  }

  // Convert Task to JSON
  Map<String, dynamic> toJson() {
    return {
      'task': task?.toJson(),
      'subTask': subTask?.toJson(),
      'client': client?.toJson(),
      'staff': staff?.toJson(),
      'financialYear': financialYear?.toJson(),
      'fromMonth': fromMonth,
      'toMonth': toMonth,
      'instructions': instructions,
      'allottedDate': allottedDate?.toIso8601String(),
      'expectedEndDate': expectedEndDate?.toIso8601String(),
      'priority': priority,
      'adminVerification': adminVerification,
    };
  }

  // Create Task from JSON
  factory NewTaskFormModel.fromJson(Map<String, dynamic> json) {
    return NewTaskFormModel(
      task: json['task'] != null ? Task.fromJson(json['task']) : null,
      subTask:
          json['subTask'] != null ? SubTask.fromJson(json['subTask']) : null,
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      staff: json['staff'] != null ? Staff.fromJson(json['staff']) : null,
      financialYear:
          json['financialYear'] != null
              ? FinancialYear.fromJson(json['financialYear'])
              : null,
      fromMonth: json['fromMonth'],
      toMonth: json['toMonth'],
      instructions: json['instructions'] ?? '',
      allottedDate:
          json['allottedDate'] != null
              ? DateTime.parse(json['allottedDate'])
              : null,
      expectedEndDate:
          json['expectedEndDate'] != null
              ? DateTime.parse(json['expectedEndDate'])
              : null,
      priority: json['priority'] ?? 'Medium',
      adminVerification: json['adminVerification'] ?? false,
    );
  }
}
