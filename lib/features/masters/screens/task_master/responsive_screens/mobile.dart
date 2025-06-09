import 'package:doc_sync/features/masters/controllers/task_master_list_controller.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/search_filter_card.dart';
import 'package:doc_sync/features/masters/screens/task_master/widgets/task_master_list.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
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
                child: RouteHeader(
                  title: 'Task Master',
                  subtitle: 'Home / Masters / Task Master',
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
} 