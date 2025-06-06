import 'package:doc_sync/features/operations/controllers/task_history_controller.dart';
import 'package:doc_sync/features/operations/screens/task_history/widgets/date_selection_card.dart';
import 'package:doc_sync/features/operations/screens/task_history/widgets/pagination_controls.dart';
import 'package:doc_sync/features/operations/screens/task_history/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/task_history/widgets/task_list.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TaskHistoryMobileScreen extends StatelessWidget {
  const TaskHistoryMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskHistoryController = Get.find<TaskHistoryController>();
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: taskHistoryController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: taskHistoryController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => taskHistoryController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Task History',
                  subtitle: 'Home / Task History / Data',
                ),
              ),

              // Date selection card
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: DateSelectionCard(
                  taskHistoryController: taskHistoryController,
                ),
              ),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  taskHistoryController: taskHistoryController,
                  searchController: searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Task list
              GetX<TaskHistoryController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const TaskListShimmer();
                  }

                  if (controller.filteredTasks.isEmpty) {
                    return const EmptyTaskList();
                  }

                  return Column(
                    children: [
                      // Task list
                      TaskList(
                        taskHistoryController: controller,
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
} 