import 'package:doc_sync/features/operations/models/admin_verification_task_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailModal extends StatelessWidget {
  final AdminVerificationTask task;

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
            _buildActionsSection(context),
            const SizedBox(height: 20),
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
        color: adminStatusToColor(task.taskStatus).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: adminStatusToColor(task.taskStatus).withOpacity(0.2),
            ),
            child: Icon(
              _getStatusIcon(task.taskStatus),
              color: adminStatusToColor(task.taskStatus),
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
              color: adminStatusToColor(task.taskStatus),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              adminStatusToString(task.taskStatus),
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
              value: adminPriorityToString(task.taskPriority),
              valueColor: adminPriorityToColor(task.taskPriority),
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
              'Task Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Allotted By',
              value: task.allottedByName,
            ),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Allotted To',
              value: task.allottedToName,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Allotted Date',
              value: _formatDate(task.allottedDate),
            ),
            _buildInfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: _formatDate(task.dateTime),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Close the modal
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Approve functionality will be handled by controller
              Navigator.of(context).pop('approve');
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  IconData _getStatusIcon(AdminTaskStatus status) {
    switch (status) {
      case AdminTaskStatus.allotted:
        return Icons.assignment_outlined;
      case AdminTaskStatus.completed:
        return Icons.check_circle_outline;
      case AdminTaskStatus.client_waiting:
        return Icons.hourglass_empty;
      case AdminTaskStatus.re_alloted:
        return Icons.refresh;
      case AdminTaskStatus.pending:
        return Icons.pending_actions;
    }
  }
} 