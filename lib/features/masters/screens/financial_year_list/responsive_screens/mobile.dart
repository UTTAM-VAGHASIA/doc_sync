import 'package:doc_sync/features/masters/controllers/financial_year_list_controller.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/financial_year_list.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/financial_year_route_header.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/search_filter_card.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class FinancialYearListMobileScreen extends StatelessWidget {
  const FinancialYearListMobileScreen({super.key});

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
      child: LiquidPullToRefresh(
        key: financialYearListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => financialYearListController.fetchFinancialYears(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: FinancialYearRouteHeader(
                  title: 'Financial Year List',
                  subtitle: 'Home / Masters / Financial Year List',
                  onAddPressed: () {
                    // Open add financial year dialog or navigate to add financial year screen
                    _showAddFinancialYearDialog(context, financialYearListController);
                  },
                ),
              ),

              const SizedBox(height: 5),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  financialYearListController: financialYearListController,
                  searchController: searchController,
                ),
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
  
  // Show dialog to add a new financial year
  void _showAddFinancialYearDialog(BuildContext context, FinancialYearListController controller) {
    final TextEditingController startYearController = TextEditingController();
    final TextEditingController endYearController = TextEditingController();
    
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
                'Add Financial Year',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Form fields
              TextField(
                controller: startYearController,
                decoration: InputDecoration(
                  labelText: 'Start Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: endYearController,
                decoration: InputDecoration(
                  labelText: 'End Year',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
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
                      if (startYearController.text.isNotEmpty &&
                          endYearController.text.isNotEmpty) {
                        // controller.addFinancialYear(
                        //   startYear: startYearController.text,
                        //   endYear: endYearController.text,
                        // );
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