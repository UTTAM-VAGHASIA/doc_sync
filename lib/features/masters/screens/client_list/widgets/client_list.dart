import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/features/masters/screens/client_list/widgets/client_card.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ClientList extends StatelessWidget {
  final ClientListController clientListController;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const ClientList({
    super.key,
    required this.clientListController,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clientListController.paginatedClients.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final client = clientListController.paginatedClients[index];
        return ClientExpansionCard(
          client: client,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        );
      },
    );
  }
}

class EmptyClientList extends StatelessWidget {
  const EmptyClientList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.user, size: 80, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No clients found with current filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter settings',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientListShimmer extends StatelessWidget {
  const ClientListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: AppShimmerEffect(width: double.infinity, height: 80),
        );
      },
    );
  }
} 