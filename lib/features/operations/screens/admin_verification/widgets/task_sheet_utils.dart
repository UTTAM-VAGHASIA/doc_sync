import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:doc_sync/features/operations/models/admin_verification_task_model.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/task_detail_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class TaskSheetUtils {
  /// Shows a task detail modal using CupertinoSheetRoute
  static Future<void> showTaskDetailSheet(
      BuildContext context, AdminVerificationTask task) async {
    final result = await Navigator.of(context, rootNavigator: true).push(
      CupertinoSheetRoute(
        builder: (context) => TaskDetailModal(task: task),
        enableDrag: true,
      ),
    );

    // Handle the result if user clicked "Approve"
    if (result == 'approve') {
      final controller = Get.find<AdminVerificationController>();
      await controller.approveTask(task);
    }
  }

  /// Shows a confirmation dialog before approving a task
  static Future<void> showApproveConfirmation(
      BuildContext context, AdminVerificationTask task) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirm Approval'),
        content: Text('Are you sure you want to approve the task "${task.taskName}"?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(context);
              final controller = Get.find<AdminVerificationController>();
              controller.approveTask(task);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
} 