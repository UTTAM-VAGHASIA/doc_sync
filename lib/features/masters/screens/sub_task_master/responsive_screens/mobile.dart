// Sub Task Master Mobile Screen
// TODO: Implement Sub Task Master Mobile screen 

import 'package:doc_sync/features/masters/controllers/sub_task_master_list_controller.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/search_filter_card.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/sub_task_master_list.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/sub_task_master_route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class SubTaskMasterMobileScreen extends StatelessWidget {
  const SubTaskMasterMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final subTaskMasterListController = Get.put(SubTaskMasterListController());
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: subTaskMasterListController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: subTaskMasterListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => subTaskMasterListController.fetchSubTaskMasters(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: SubTaskMasterRouteHeader(
                  title: 'Sub Task Master',
                  subtitle: 'Home / Masters / Sub Task Master',
                  onAddPressed: () {
                    // Open add sub task dialog
                    _showAddSubTaskDialog(context, subTaskMasterListController);
                  },
                ),
              ),

              const SizedBox(height: 5),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  subTaskMasterListController: subTaskMasterListController,
                  searchController: searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Sub task master list
              GetX<SubTaskMasterListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const SubTaskMasterListShimmer();
                  }

                  if (controller.filteredSubTaskMasters.isEmpty) {
                    return const EmptySubTaskMasterList();
                  }

                  return Column(
                    children: [
                      // Sub Task master list
                      SubTaskMasterList(
                        subTaskMasterListController: controller,
                        cardBackgroundColor: cardBackgroundColor,
                        textColor: textColor,
                        subtleTextColor: subtleTextColor,
                      ),

                      // Pagination controls
                      PaginationControls(
                        controller: controller,
                        cardBackgroundColor: cardBackgroundColor,
                        textColor: textColor,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Show dialog to add a new sub task
  void _showAddSubTaskDialog(BuildContext context, SubTaskMasterListController controller) {
    // First need to select a task
    final TextEditingController subTaskNameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog header
              Text(
                'Add Sub Task',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // // Form fields for task selection and sub task name
              // DropdownButtonFormField(
              //   decoration: InputDecoration(
              //     labelText: 'Select Task',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //   ),
              //   items: controller.tasksList.map((task) {
              //     return DropdownMenuItem(
              //       value: task.taskId,
              //       child: Text(task.taskName),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     controller.setSelectedTaskId(value.toString());
              //   },
              // ),
              const SizedBox(height: 16),
              TextField(
                controller: subTaskNameController,
                decoration: InputDecoration(
                  labelText: 'Sub Task Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // if (controller.selectedTaskId.isNotEmpty && 
                      //     subTaskNameController.text.isNotEmpty) {
                      //   controller.addSubTask(
                      //     controller.selectedTaskId,
                      //     subTaskNameController.text,
                      //   );
                        Navigator.pop(context);
                      // }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 