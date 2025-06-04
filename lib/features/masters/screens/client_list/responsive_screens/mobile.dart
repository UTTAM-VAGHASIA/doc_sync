import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/features/masters/models/client_model.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/client_list.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/search_filter_card.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ClientListMobileScreen extends StatelessWidget {
  const ClientListMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final clientListController = Get.put(ClientListController());
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: clientListController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: clientListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => clientListController.fetchClients(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Client List',
                  subtitle: 'Home / Masters / Client List',
                ),
              ),

              const SizedBox(height: 16),

              // Search and filter card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchFilterCard(
                  clientListController: clientListController,
                  searchController: searchController,
                ),
              ),

              const SizedBox(height: 16),

              // Client list
              GetX<ClientListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return const ClientListShimmer();
                  }

                  if (controller.filteredClients.isEmpty) {
                    return const EmptyClientList();
                  }

                  return Column(
                    children: [
                      // Client list
                      ClientList(
                        clientListController: controller,
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