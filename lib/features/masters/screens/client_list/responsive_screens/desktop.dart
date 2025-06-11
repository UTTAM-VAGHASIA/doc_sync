import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/client_list.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/client_route_header.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/pagination_controls.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/search_filter_card.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientListDesktopScreen extends StatelessWidget {
  const ClientListDesktopScreen({super.key});

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
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ClientRouteHeader(
                title: 'Client List',
                subtitle: 'Home / Masters / Client List',
                onAddPressed: () {
                  // Navigate to the add client screen
                  Get.toNamed(AppRoutes.addClient);
                },
              ),
            ),

            // Search and filter card
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SearchFilterCard(
                clientListController: clientListController,
                searchController: searchController,
              ),
            ),

            // Client list
            Expanded(
              child: GetX<ClientListController>(
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
                      Expanded(
                        child: ClientList(
                          clientListController: controller,
                          cardBackgroundColor: cardBackgroundColor,
                          textColor: textColor,
                          subtleTextColor: subtleTextColor,
                        ),
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
            ),
          ],
        ),
      ),
    );
  }
} 