import 'package:doc_sync/features/operations/controllers/task_history_controller.dart';
import 'package:doc_sync/features/operations/models/task_history_model.dart';
import 'package:doc_sync/features/operations/screens/task_history/widgets/task_detail_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TaskSheetUtils {
  /// Shows a task detail modal using CupertinoSheetRoute
  static Future<void> showTaskDetailSheet(
      BuildContext context, TaskHistoryTask task) async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      CupertinoSheetRoute(
        builder: (context) => TaskDetailModal(task: task),
        enableDrag: true,
      ),
    );

    // No action needed for task history view since it's read-only
  }
} 