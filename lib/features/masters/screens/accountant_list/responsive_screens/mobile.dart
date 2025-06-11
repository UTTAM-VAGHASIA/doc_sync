import 'package:doc_sync/features/masters/controllers/accountant_list_controller.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/accountant_list.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/accountant_route_header.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/search_filter_card.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class AccountantListMobileScreen extends StatelessWidget {
  const AccountantListMobileScreen({super.key});

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
      child: LiquidPullToRefresh(
        key: accountantListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => accountantListController.fetchAccountants(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: AccountantRouteHeader(
                  title: 'Accountant List',
                  subtitle: 'Home / Masters / Accountant List',
                  onAddPressed: () {
                    // Open add accountant dialog
                    _showAddAccountantDialog(context, accountantListController);
                  },
                ),
              ),

              const SizedBox(height: 5),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  accountantListController: accountantListController,
                  searchController: searchController,
                ),
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

  // Show dialog to add a new accountant
  void _showAddAccountantDialog(BuildContext context, AccountantListController controller) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController contact1Controller = TextEditingController();
    final TextEditingController contact2Controller = TextEditingController();
    
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
                'Add Accountant',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Form fields
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Accountant Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contact1Controller,
                decoration: InputDecoration(
                  labelText: 'Primary Contact',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contact2Controller,
                decoration: InputDecoration(
                  labelText: 'Secondary Contact (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
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
                      if (nameController.text.isNotEmpty && 
                          contact1Controller.text.isNotEmpty) {
                        // controller.addAccountant(
                        //   name: nameController.text,
                        //   contact1: contact1Controller.text,
                        //   contact2: contact2Controller.text,
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