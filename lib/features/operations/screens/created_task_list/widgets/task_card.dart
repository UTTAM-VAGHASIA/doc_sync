import 'dart:convert';

import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/widgets/edit_task_modal_sheet.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/helpers/network_manager.dart';
import 'package:doc_sync/utils/helpers/retry_queue_manager.dart';
import 'package:doc_sync/utils/http/http_client.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskExpansionCard extends StatefulWidget {
  final Task task;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;
  
  const TaskExpansionCard({super.key, 
    required this.task,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });
  
  @override
  TaskExpansionCardState createState() => TaskExpansionCardState();
}

class TaskExpansionCardState extends State<TaskExpansionCard> with SingleTickerProviderStateMixin {
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
    _heightFactor = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
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
                      color: statusToColor(widget.task.status).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: getStatusIcon(widget.task.status)),
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
                          widget.task.client ?? 'No client',
                          style: TextStyle(fontSize: 12, color: widget.subtleTextColor),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityToColor(widget.task.priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priorityToString(widget.task.priority),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: priorityToColor(widget.task.priority),
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
                child: Align(
                  heightFactor: _heightFactor.value,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.0,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Actions menu
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          color: Colors.green,
                          onTap: () async {
                            await _showEditTaskBottomSheet(context);
                          },
                        ),
                        SizedBox(width: 16),
                        _buildActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () {
                            _showDeleteConfirmation(context);
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
                          statusToString(widget.task.status),
                          Icons.flag_outlined,
                          statusToColor(widget.task.status),
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
                          widget.task.fileNo ?? 'N/A',
                          Icons.folder_outlined,
                          Colors.blue,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Sub Task',
                          widget.task.taskSubTask ?? 'N/A',
                          Icons.subtitles_outlined,
                          Colors.teal,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted By',
                          widget.task.allottedBy ?? 'N/A',
                          Icons.person_outline,
                          Colors.purple,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted To',
                          widget.task.allottedTo ?? 'N/A',
                          Icons.person_outline,
                          Colors.indigo,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Allotted Date',
                          formatTaskDate(widget.task.allottedDate),
                          Icons.calendar_today_outlined,
                          Colors.orange,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Expected End Date',
                          formatTaskDate(widget.task.expectedEndDate),
                          Icons.calendar_month_outlined,
                          Colors.red,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Period',
                          widget.task.period ?? 'N/A',
                          Icons.date_range_outlined,
                          Colors.green,
                          widget.textColor,
                          isLast: true,
                        ),
                        if (widget.task.instructions != null &&
                            widget.task.instructions!.isNotEmpty)
                          buildInstructionsSection(
                            context,
                            widget.task.instructions!,
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
  
  Future<void> _showEditTaskBottomSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTaskBottomSheet(task: widget.task),
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
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
  
  // Helper functions
  Widget getStatusIcon(TaskStatus? status) {
    Color color = statusToColor(status);
    IconData icon;

    switch (status) {
      case TaskStatus.allotted:
        icon = Icons.assignment_outlined;
        break;
      case TaskStatus.completed:
        icon = Icons.check_circle_outline;
        break;
      case TaskStatus.client_waiting:
        icon = Icons.hourglass_empty;
        break;
      case TaskStatus.re_alloted:
        icon = Icons.replay_outlined;
        break;
      case TaskStatus.pending:
        icon = Icons.pending_actions_outlined;
        break;
      default:
        icon = Icons.help_outline;
        break;
    }

    return Icon(icon, color: color, size: 20);
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
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
        if(!isLast) Divider(color: Colors.grey.shade200, height: 1),
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
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: textColor),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    Get.defaultDialog(
      title: "", // Empty title to match the style
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      backgroundColor: AppColors.white,
      radius: 20,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon header
          Icon(Icons.delete_forever, size: 60, color: Colors.red.shade600),
          const SizedBox(height: 10),
          
          // Title
          Text(
            "Delete Task",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          
          // Task name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.task.taskName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Warning message
          Text(
            "This action cannot be undone. All information associated with this task will be permanently deleted.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(width: 0),
                    elevation: 6,
                    foregroundColor: Colors.grey[700],
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              
              // Delete button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // Close dialog
                    _deleteTask(); // Delete the task
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    side: BorderSide(width: 0),
                    foregroundColor: AppColors.white,
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Delete"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Handle task deletion
  Future<void> _deleteTask() async {
    try {
      // Check network connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        RetryQueueManager.instance.addJob(() => _deleteTask());
        AppLoaders.customToast(
          message: 'Offline. Will retry when back online.',
        );
        return;
      }
      
      // Prepare API request payload
      final payload = {
        'id': widget.task.srNo,
      };
      
      // Log request for debugging
      print('[API REQUEST] delete_task_creation payload: ${jsonEncode(payload)}');
      
      // Make API request
      final data = await AppHttpHelper().sendMultipartRequest(
        'delete_task_creation',
        method: 'POST',
        fields: {'data': jsonEncode(payload)},
      );
      
      // Log response for debugging
      print('[API RESPONSE] delete_task_creation: $data');
      
      // Handle API response
      if (data['success'] == true) {
        // Show success message
        AppLoaders.successSnackBar(
          title: 'Success',
          message: data['message'] ?? 'Task deleted successfully',
        );
        
        // Refresh task list if available
        if (Get.isRegistered<TaskListController>()) {
          final taskListController = Get.find<TaskListController>();
          taskListController.fetchTasks();
        }
      } else {
        // Show error message
        AppLoaders.errorSnackBar(
          title: 'Error',
          message: data['message'] ?? 'Failed to delete task',
        );
      }
    } catch (e) {
      // Show error message
      AppLoaders.errorSnackBar(
        title: 'Error',
        message: 'An error occurred: ${e.toString()}',
      );
    }
  }
}