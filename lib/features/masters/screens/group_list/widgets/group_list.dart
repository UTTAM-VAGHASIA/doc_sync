import 'package:doc_sync/features/masters/controllers/group_list_controller.dart';
import 'package:doc_sync/features/masters/models/group_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class GroupList extends StatelessWidget {
  final GroupListController groupListController;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const GroupList({
    super.key,
    required this.groupListController,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = groupListController.paginatedGroups;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groups.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupExpansionCard(
            group: group,
            cardBackgroundColor: cardBackgroundColor,
            textColor: textColor,
            subtleTextColor: subtleTextColor,
          );
        },
      );
    });
  }
}

class GroupExpansionCard extends StatefulWidget {
  final Group group;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const GroupExpansionCard({
    super.key,
    required this.group,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  State<GroupExpansionCard> createState() => _GroupExpansionCardState();
}

class _GroupExpansionCardState extends State<GroupExpansionCard> with SingleTickerProviderStateMixin {
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
    final bool isEnabled = widget.group.status.toLowerCase() == 'enable';
    
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
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Iconsax.task_square,
                        color: isEnabled ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.groupName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Client: ${widget.group.clientName}",
                          style: TextStyle(fontSize: 12, color: widget.subtleTextColor),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isEnabled 
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isEnabled ? 'Enabled' : 'Disabled',
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
                          label: 'View',
                          icon: Iconsax.eye,
                          color: Colors.blue,
                          onTap: () {
                            Get.find<GroupListController>().viewGroupDetails(widget.group);
                          },
                        ),
                        _buildActionButton(
                          label: 'Edit',
                          icon: Iconsax.edit,
                          color: Colors.green,
                          onTap: () {
                            Get.find<GroupListController>().editGroup(widget.group);
                          },
                        ),
                        _buildActionButton(
                          label: 'Delete',
                          icon: Iconsax.trash,
                          color: Colors.red,
                          onTap: () {
                            // Show delete confirmation dialog
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Delete Group'),
                                content: Text(
                                  'Are you sure you want to delete ${widget.group.groupName}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.find<GroupListController>()
                                          .deleteGroup(widget.group.id);
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
                  
                  // Group details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          title: "ID", 
                          value: widget.group.id, 
                          icon: Iconsax.code,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "Client Group ID", 
                          value: widget.group.clientGroupId, 
                          icon: Iconsax.code,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "Group Name", 
                          value: widget.group.groupName, 
                          icon: Iconsax.task_square,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "Client Name", 
                          value: widget.group.clientName, 
                          icon: Iconsax.user,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          title: "Status", 
                          value: widget.group.status, 
                          icon: isEnabled ? Iconsax.tick_circle : Iconsax.close_circle,
                          textColor: widget.textColor,
                          subtleTextColor: widget.subtleTextColor,
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

  // Helper method to build action buttons
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
  
  // Helper method to build detail rows
  Widget _buildDetailRow({
    required String title,
    required String value,
    required IconData icon,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: subtleTextColor,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subtleTextColor,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Empty state widget
class EmptyGroupList extends StatelessWidget {
  const EmptyGroupList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.task_square, size: 80, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No groups found with current filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter settings',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer loading effect for group list
class GroupListShimmer extends StatelessWidget {
  const GroupListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: AppShimmerEffect(width: double.infinity, height: 80),
        );
      },
    );
  }
} 