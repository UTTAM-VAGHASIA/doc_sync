import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/widgets/date_selection_card.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/widgets/task_list.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class TaskListMobileScreen extends StatelessWidget {
  const TaskListMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskListController = Get.find<TaskListController>();
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: taskListController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: taskListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => taskListController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Created Tasks List',
                  subtitle: 'Home / Created Tasks List / Data',
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
                  taskListController: taskListController,
                ),
              ),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  taskListController: taskListController,
                  searchController: searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Task list
              GetX<TaskListController>(
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
                        taskListController: controller,
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
