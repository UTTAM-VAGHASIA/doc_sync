import 'package:doc_sync/features/operations/models/admin_verification_task_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

// Helper functions for status
String adminStatusToString(AdminTaskStatus status) {
  switch (status) {
    case AdminTaskStatus.allotted:
      return 'Allotted';
    case AdminTaskStatus.completed:
      return 'Completed';
    case AdminTaskStatus.awaiting:
      return 'Awaiting';
    case AdminTaskStatus.reallotted:
      return 'Reallotted';
  }
}

Color adminStatusToColor(AdminTaskStatus status) {
  switch (status) {
    case AdminTaskStatus.allotted:
      return Colors.blue;
    case AdminTaskStatus.completed:
      return Colors.green;
    case AdminTaskStatus.awaiting:
      return Colors.orange;
    case AdminTaskStatus.reallotted:
      return Colors.purple;
  }
}

// Helper functions for priority
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
      return Colors.red;
    case AdminTaskPriority.medium:
      return Colors.orange;
    case AdminTaskPriority.low:
      return Colors.green;
  }
}

class TaskExpansionCard extends StatefulWidget {
  final AdminVerificationTask task;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const TaskExpansionCard({
    super.key,
    required this.task,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  TaskExpansionCardState createState() => TaskExpansionCardState();
}

class TaskExpansionCardState extends State<TaskExpansionCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightFactor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: widget.cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Main task header - always visible
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(isExpanded ? 0 : 12),
              bottomRight: Radius.circular(isExpanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: adminStatusToColor(
                        widget.task.taskStatus,
                      ).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: getStatusIcon(widget.task.taskStatus)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.taskName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.task.clientName,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.subtleTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: adminPriorityToColor(
                        widget.task.taskPriority,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      adminPriorityToString(widget.task.taskPriority),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: adminPriorityToColor(widget.task.taskPriority),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated expanded content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRect(
                child: Align(heightFactor: _heightFactor.value, child: child),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Actions menu
                  Container(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          label: 'View',
                          icon: Icons.visibility_outlined,
                          color: Colors.blue,
                          onTap: () {
                            // View functionality will be implemented later
                          },
                        ),
                        _buildActionButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          color: Colors.green,
                          onTap: () {
                            // Edit functionality will be implemented later
                          },
                        ),
                        _buildActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () {
                            // Delete functionality will be implemented later
                          },
                        ),
                      ],
                    ),
                  ),

                  // Divider between actions and details
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                  // Task details
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        // Task details
                        buildDetailRow(
                          context,
                          'Status',
                          adminStatusToString(widget.task.taskStatus),
                          Icons.flag_outlined,
                          adminStatusToColor(widget.task.taskStatus),
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Task ID',
                          widget.task.taskId,
                          Icons.tag,
                          AppColors.primary,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'File No',
                          widget.task.fileNo,
                          Icons.folder_outlined,
                          Colors.blue,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Sub Task',
                          widget.task.subTaskName,
                          Icons.subtitles_outlined,
                          Colors.teal,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted By',
                          widget.task.allottedByName,
                          Icons.person_outline,
                          Colors.purple,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted To',
                          widget.task.allottedToName,
                          Icons.person_outline,
                          Colors.purple,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Period',
                          widget.task.period,
                          Icons.calendar_today_outlined,
                          Colors.orange,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted Date',
                          widget.task.allottedDate,
                          Icons.event_outlined,
                          Colors.green,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Expected End Date',
                          widget.task.expectedEndDate,
                          Icons.event_outlined,
                          Colors.red,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Instructions',
                          widget.task.instruction,
                          Icons.description_outlined,
                          Colors.blue,
                          widget.textColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: widget.subtleTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getStatusIcon(AdminTaskStatus status) {
    switch (status) {
      case AdminTaskStatus.allotted:
        return const Icon(Icons.assignment_outlined, color: Colors.blue);
      case AdminTaskStatus.completed:
        return const Icon(Icons.check_circle_outline, color: Colors.green);
      case AdminTaskStatus.awaiting:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case AdminTaskStatus.reallotted:
        return const Icon(Icons.replay_outlined, color: Colors.red);
    }
  }
}
