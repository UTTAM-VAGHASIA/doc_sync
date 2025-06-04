import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/date_selection_card.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/pagination_controls.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/task_list.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AdminVerificationMobileScreen extends StatelessWidget {
  const AdminVerificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVerificationController = Get.find<AdminVerificationController>();
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: adminVerificationController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: adminVerificationController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => adminVerificationController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Admin Verification',
                  subtitle: 'Home / Admin Verification / Data',
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
                  adminVerificationController: adminVerificationController,
                ),
              ),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  adminVerificationController: adminVerificationController,
                  searchController: searchController,
                          ),
                        ),

                        const SizedBox(height: 16),

              // Task list
              GetX<AdminVerificationController>(
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
                        adminVerificationController: controller,
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
