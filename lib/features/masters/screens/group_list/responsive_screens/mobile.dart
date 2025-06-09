import 'package:doc_sync/features/masters/controllers/group_list_controller.dart';
import 'package:doc_sync/features/masters/screens/group_list/widgets/group_list.dart';
import 'package:doc_sync/features/masters/screens/group_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/group_list/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GroupListMobileScreen extends StatelessWidget {
  const GroupListMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final groupListController = Get.put(GroupListController());
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: groupListController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: groupListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => groupListController.fetchGroups(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Group List',
                  subtitle: 'Home / Masters / Group List',
                ),
              ),

              const SizedBox(height: 5),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  groupListController: groupListController,
                  searchController: searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Group list
              GetX<GroupListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const GroupListShimmer();
                  }

                  if (controller.filteredGroups.isEmpty) {
                    return const EmptyGroupList();
                  }

                  return Column(
                    children: [
                      // Group list
                      GroupList(
                        groupListController: controller,
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