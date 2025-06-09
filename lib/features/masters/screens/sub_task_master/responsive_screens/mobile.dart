// Sub Task Master Mobile Screen
// TODO: Implement Sub Task Master Mobile screen 

import 'package:doc_sync/features/masters/controllers/sub_task_master_list_controller.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/search_filter_card.dart';
import 'package:doc_sync/features/masters/screens/sub_task_master/widgets/sub_task_master_list.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
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
                child: RouteHeader(
                  title: 'Sub Task Master',
                  subtitle: 'Home / Masters / Sub Task Master',
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
} 