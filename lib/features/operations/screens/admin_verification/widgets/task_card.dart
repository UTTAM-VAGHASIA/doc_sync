import 'package:doc_sync/features/operations/models/admin_verification_task_model.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/task_sheet_utils.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

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
                      ).withValues(alpha:0.1),
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
                      ).withValues(alpha:0.1),
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
                            // Show task detail sheet
                            TaskSheetUtils.showTaskDetailSheet(context, widget.task);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          label: 'Approve',
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                          onTap: () {
                            TaskSheetUtils.showApproveConfirmation(context, widget.task);
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
                          Colors.indigo,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted Date',
                          widget.task.allottedDate,
                          Icons.calendar_today_outlined,
                          Colors.orange,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Expected End Date',
                          widget.task.expectedEndDate,
                          Icons.calendar_month_outlined,
                          Colors.red,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Period',
                          widget.task.period,
                          Icons.date_range_outlined,
                          Colors.green,
                          widget.textColor,
                          isLast: widget.task.instruction.isEmpty && widget.task.verifyByAdmin.isEmpty,
                        ),
                        if (widget.task.verifyByAdmin.isNotEmpty)
                          buildDetailRow(
                            context,
                            'Verification Status',
                            widget.task.verifyByAdmin == '1' ? 'Pending' : 'Verified',
                            Icons.verified_outlined,
                            widget.task.verifyByAdmin == '1' ? Colors.amber : Colors.teal,
                            widget.textColor,
                            isLast: widget.task.instruction.isEmpty,
                          ),
                        if (widget.task.instruction.isNotEmpty)
                          buildInstructionsSection(
                            context,
                            widget.task.instruction,
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha:0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
    Color textColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  Widget buildInstructionsSection(
    BuildContext context,
    String instructions,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade200, height: 1),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            instructions,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget getStatusIcon(AdminTaskStatus status) {
    Color color = adminStatusToColor(status);
    IconData icon;

    switch (status) {
      case AdminTaskStatus.allotted:
        icon = Icons.assignment_outlined;
        break;
      case AdminTaskStatus.completed:
        icon = Icons.check_circle_outline;
        break;
      case AdminTaskStatus.client_waiting:
        icon = Icons.hourglass_empty;
        break;
      case AdminTaskStatus.re_alloted:
        icon = Icons.replay_outlined;
        break;
      case AdminTaskStatus.pending:
        icon = Icons.pending_actions_outlined;
        break;
    }

    return Icon(icon, color: color, size: 20);
  }
}
