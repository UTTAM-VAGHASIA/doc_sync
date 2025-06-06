import 'package:doc_sync/features/operations/models/task_history_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailModal extends StatelessWidget {
  final TaskHistoryTask task;

  const TaskDetailModal({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Task Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: CupertinoColors.systemBackground.resolveFrom(context),
        trailing: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Text(
            'Close',
            style: TextStyle(
              color: CupertinoColors.activeBlue,
            ),
          ),
        ),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 20),
            _buildTaskDetails(context),
            const SizedBox(height: 20),
            _buildTimelineCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: taskHistoryStatusToColor(task.taskStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: taskHistoryStatusToColor(task.taskStatus).withOpacity(0.2),
            ),
            child: Icon(
              _getStatusIcon(task.taskStatus),
              color: taskHistoryStatusToColor(task.taskStatus),
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            task.taskName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: taskHistoryStatusToColor(task.taskStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              taskHistoryStatusToString(task.taskStatus),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.business,
              label: 'Client Name',
              value: task.clientName,
            ),
            _buildInfoRow(
              icon: Icons.folder_outlined,
              label: 'File Number',
              value: task.fileNo,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Financial Year',
              value: task.financialYear,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskDetails(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.task_alt,
              label: 'Task ID',
              value: task.taskId,
            ),
            _buildInfoRow(
              icon: Icons.subtitles_outlined,
              label: 'Sub Task',
              value: task.subTaskName,
            ),
            _buildInfoRow(
              icon: Icons.flag_outlined,
              label: 'Priority',
              value: taskHistoryPriorityToString(task.taskPriority),
              valueColor: taskHistoryPriorityToColor(task.taskPriority),
            ),
            _buildInfoRow(
              icon: Icons.date_range_outlined,
              label: 'Allotted Date',
              value: _formatDate(task.allottedDate),
            ),
            _buildInfoRow(
              icon: Icons.date_range_outlined,
              label: 'Expected End Date',
              value: _formatDate(task.expectedEndDate),
            ),
            _buildInfoRow(
              icon: Icons.calendar_month_outlined,
              label: 'Period',
              value: task.period,
            ),
            if (task.instruction.isNotEmpty)
              _buildInfoRow(
                icon: Icons.info_outline,
                label: 'Instructions',
                value: task.instruction,
                isVertical: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allocation Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person_outlined,
              label: 'Allotted To',
              value: task.allottedToName,
            ),
            _buildInfoRow(
              icon: Icons.person_outlined,
              label: 'Allotted By',
              value: task.allottedByName,
            ),
            _buildInfoRow(
              icon: Icons.date_range_outlined,
              label: 'Allotted Date',
              value: _formatDate(task.allottedDate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isVertical = false,
  }) {
    if (isVertical) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getStatusIcon(TaskHistoryStatus status) {
    switch (status) {
      case TaskHistoryStatus.allotted:
        return Icons.assignment_outlined;
      case TaskHistoryStatus.completed:
        return Icons.check_circle_outline;
      case TaskHistoryStatus.client_waiting:
        return Icons.hourglass_empty;
      case TaskHistoryStatus.re_alloted:
        return Icons.replay_outlined;
      case TaskHistoryStatus.pending:
        return Icons.pending_actions_outlined;
    }
  }
} 