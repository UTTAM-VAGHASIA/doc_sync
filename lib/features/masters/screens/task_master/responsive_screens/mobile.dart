import 'package:doc_sync/features/masters/controllers/task_master_list_controller.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/search_filter_card.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/task_master_list.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/task_master_route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TaskMasterMobileScreen extends StatelessWidget {
  const TaskMasterMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final taskMasterListController = Get.put(TaskMasterListController());
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: taskMasterListController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: taskMasterListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => taskMasterListController.fetchTaskMasters(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: TaskMasterRouteHeader(
                  title: 'Task Master',
                  subtitle: 'Home / Masters / Task Master',
                  onAddPressed: () {
                    // Open add task dialog
                    _showAddTaskDialog(context, taskMasterListController);
                  },
                ),
              ),

              const SizedBox(height: 5),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  taskMasterListController: taskMasterListController,
                  searchController: searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Task master list
              GetX<TaskMasterListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const TaskMasterListShimmer();
                  }

                  if (controller.filteredTaskMasters.isEmpty) {
                    return const EmptyTaskMasterList();
                  }

                  return Column(
                    children: [
                      // Task master list
                      TaskMasterList(
                        taskMasterListController: controller,
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
  
  // Show dialog to add a new task
  void _showAddTaskDialog(BuildContext context, TaskMasterListController controller) {
    final TextEditingController taskNameController = TextEditingController();
    
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
                'Add Task',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Form fields
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
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
                      if (taskNameController.text.isNotEmpty) {
                        // controller.addTask(taskNameController.text);
                        Navigator.pop(context);
                      }
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