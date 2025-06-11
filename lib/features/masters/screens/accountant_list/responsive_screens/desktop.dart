// Accountant List Desktop Screen

import 'package:doc_sync/features/masters/controllers/accountant_list_controller.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/accountant_list.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountantListDesktopScreen extends StatelessWidget {
  const AccountantListDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final accountantListController = Get.put(AccountantListController());
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: accountantListController.searchQuery.value,
    );

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              RouteHeader(
                title: 'Accountant List',
                subtitle: 'Home / Masters / Accountant List',
              ),

              const SizedBox(height: 16),

              // Search and filter card
              SearchFilterCard(
                accountantListController: accountantListController,
                searchController: searchController,
              ),

              const SizedBox(height: 16),

              // Accountant list
              GetX<AccountantListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const AccountantListShimmer();
                  }

                  if (controller.filteredAccountants.isEmpty) {
                    return const EmptyAccountantList();
                  }

                  return Column(
                    children: [
                      // Accountant list
                      AccountantList(
                        accountantListController: controller,
                        cardBackgroundColor: cardBackgroundColor,
                        textColor: textColor,
                        subtleTextColor: subtleTextColor,
                      ),

                      const SizedBox(height: 16),

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