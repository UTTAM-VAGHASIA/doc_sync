import 'package:doc_sync/features/masters/controllers/financial_year_list_controller.dart';
import 'package:doc_sync/features/masters/screens/financial_year_list/widgets/financial_year_card.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinancialYearList extends StatelessWidget {
  final FinancialYearListController financialYearListController;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const FinancialYearList({
    super.key,
    required this.financialYearListController,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final financialYears = financialYearListController.paginatedFinancialYears;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: financialYears.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final financialYear = financialYears[index];
          return FinancialYearExpansionCard(
            financialYear: financialYear,
            cardBackgroundColor: cardBackgroundColor,
            textColor: textColor,
            subtleTextColor: subtleTextColor,
          );
        },
      );
    });
  }
}

class EmptyFinancialYearList extends StatelessWidget {
  const EmptyFinancialYearList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No financial years found',
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

class FinancialYearListShimmer extends StatelessWidget {
  const FinancialYearListShimmer({super.key});

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