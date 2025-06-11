// Financial Year List Desktop Screen

import 'package:doc_sync/features/masters/controllers/financial_year_list_controller.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/financial_year_list.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancialYearListDesktopScreen extends StatelessWidget {
  const FinancialYearListDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final financialYearListController = Get.put(FinancialYearListController());
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: financialYearListController.searchQuery.value,
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
                title: 'Financial Year List',
                subtitle: 'Home / Masters / Financial Year List',
              ),

              const SizedBox(height: 16),

              // Search and filter card
              SearchFilterCard(
                financialYearListController: financialYearListController,
                searchController: searchController,
              ),

              const SizedBox(height: 16),

              // Financial Year list
              GetX<FinancialYearListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const FinancialYearListShimmer();
                  }

                  if (controller.filteredFinancialYears.isEmpty) {
                    return const EmptyFinancialYearList();
                  }

                  return Column(
                    children: [
                      // Financial Year list
                      FinancialYearList(
                        financialYearListController: controller,
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