import 'package:doc_sync/features/masters/controllers/accountant_list_controller.dart';
import 'package:doc_sync/features/masters/screens/accountant_list/widgets/accountant_card.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountantList extends StatelessWidget {
  final AccountantListController accountantListController;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const AccountantList({
    super.key,
    required this.accountantListController,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final accountants = accountantListController.paginatedAccountants;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: accountants.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final accountant = accountants[index];
          return AccountantExpansionCard(
            accountant: accountant,
            cardBackgroundColor: cardBackgroundColor,
            textColor: textColor,
            subtleTextColor: subtleTextColor,
          );
        },
      );
    });
  }
}

class EmptyAccountantList extends StatelessWidget {
  const EmptyAccountantList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No accountants found',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountantListShimmer extends StatelessWidget {
  const AccountantListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AppShimmerEffect(
          width: double.infinity,
          height: 80,
          radius: 12,
        ),
      ),
    );
  }
} 