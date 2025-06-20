// Sub Task Master Card Widget
// TODO: Implement Sub Task Master Card 

import 'package:doc_sync/features/masters/controllers/sub_task_master_list_controller.dart';
import 'package:doc_sync/features/masters/models/sub_task_master_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubTaskMasterExpansionCard extends StatefulWidget {
  final SubTaskMaster subTaskMaster;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const SubTaskMasterExpansionCard({
    super.key,
    required this.subTaskMaster,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  State<SubTaskMasterExpansionCard> createState() => SubTaskMasterExpansionCardState();
}

class SubTaskMasterExpansionCardState extends State<SubTaskMasterExpansionCard> with SingleTickerProviderStateMixin {
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
    final bool isEnabled = widget.subTaskMaster.status.toLowerCase() == 'enable';
    
    return Card(
      elevation: 2,
      color: widget.cardBackgroundColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header section with expand button
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isExpanded ? 0 : 12),
              bottomRight: Radius.circular(isExpanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.layers_outlined,
                        color: isEnabled ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subTaskMaster.subTaskName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.textColor,
                          ),
                          softWrap: true,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Task: ${widget.subTaskMaster.taskName}",
                          style: TextStyle(fontSize: 12, color: widget.subtleTextColor),
                          softWrap: true,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.subTaskMaster.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isEnabled ? Colors.green : Colors.red,
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
                          onTap: () {
                            Get.find<SubTaskMasterListController>().editSubTaskMaster(widget.subTaskMaster);
                          },
                        ),
                        const SizedBox(width: 16),
                        _buildActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          onTap: () {
                            // Show delete confirmation dialog
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Delete Sub Task'),
                                content: Text(
                                  'Are you sure you want to delete ${widget.subTaskMaster.subTaskName}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.find<SubTaskMasterListController>().deleteSubTaskMaster(widget.subTaskMaster.id);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider between actions and details
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
                  
                  // Sub Task master details
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      children: [
                        buildDetailRow(
                          context,
                          'ID',
                          widget.subTaskMaster.id,
                          Icons.tag,
                          AppColors.primary,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Task ID',
                          widget.subTaskMaster.taskId,
                          Icons.link,
                          Colors.purple,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Task Name',
                          widget.subTaskMaster.taskName,
                          Icons.assignment_outlined,
                          Colors.blue,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Sub Task Name',
                          widget.subTaskMaster.subTaskName,
                          Icons.layers_outlined,
                          Colors.teal,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Amount',
                          '₹${widget.subTaskMaster.amount}',
                          Icons.attach_money,
                          Colors.green.shade800,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Date & Time',
                          formatDateTime(widget.subTaskMaster.dateTime),
                          Icons.access_time,
                          Colors.orange,
                          widget.textColor,
                        ),
                        buildDetailRow(
                          context,
                          'Status',
                          widget.subTaskMaster.status,
                          isEnabled ? Icons.check_circle_outline : Icons.cancel_outlined,
                          isEnabled ? Colors.green : Colors.red,
                          widget.textColor,
                          isLast: true,
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  softWrap: true,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        if(!isLast) Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
  
  String formatDateTime(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateTime;
    }
  }
} 