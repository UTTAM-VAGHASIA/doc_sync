// Helper Widget for Summary Cards
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/widgets/summary_cards.dart';
import 'package:flutter/material.dart';

Widget buildResponsiveCardGrid({
  required BuildContext context,
  required List<int> cardsData,
  required int crossAxisCount,
  required Color cardBackgroundColor,
  required Color textColor,
  required Color subtleTextColor,
  double cardSpacing = 16.0, // Spacing between cards
  bool isLoading = false, // Add loading state parameter
}) {
  List<Widget> rows = [];
  final List<Map<String, dynamic>> summaryCardsData = [
      {
        'title': 'Tasks Created',
        'value': cardsData[0].toString(),
        'icon': Icons.list_alt_outlined,
        'iconColor': Colors.blue,
        'subtitle': 'Today',
      },
      {
        'title': 'Tasks Completed',
        'value': cardsData[1].toString(),
        'icon': Icons.check_circle_outline,
        'iconColor': Colors.green,
        'subtitle': 'Today',
      },
      {
        'title': 'Pending (Today)',
        'value': cardsData[2].toString(),
        'icon': Icons.pending_actions_outlined,
        'iconColor': Colors.orange,
        'subtitle': 'Today (Pending + Allotted + Re-Allotted)',
      },
      {
        'title': 'Pending (Total)',
        'value': cardsData[3].toString(),
        'icon': Icons.hourglass_top_outlined,
        'iconColor': Colors.redAccent,
        'subtitle': '(Total Pending + Allotted + Re-Allotted)',
      },
      {
        'title': 'High Priority',
        'value': cardsData[4].toString(),
        'icon': Icons.priority_high_rounded,
        'iconColor': Colors.red,
        'subtitle': '(Total Pending + Allotted + Re-Allotted)',
      },
      {
        'title': 'Running Late',
        'value': cardsData[5].toString(),
        'icon': Icons.running_with_errors_outlined,
        'iconColor': Colors.deepOrange,
        'subtitle': '(Total Pending + Allotted + Re-Allotted)',
      },
    ];

  int totalCards = summaryCardsData.length;

  for (int i = 0; i < totalCards; i += crossAxisCount) {
    List<Widget> rowChildren = [];
    for (int j = 0; j < crossAxisCount; j++) {
      int cardIndex = i + j;
      if (cardIndex < totalCards) {
        // Add Expanded Card
        rowChildren.add(
          Expanded(
            child: buildSummaryCard(
              context: context,
              title: summaryCardsData[cardIndex]['title'],
              valueWidget: isLoading
                ? AppShimmerEffect(width: 80, height: 30)
                : Text(
                    summaryCardsData[cardIndex]['value'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
              icon: summaryCardsData[cardIndex]['icon'],
              iconColor: summaryCardsData[cardIndex]['iconColor'],
              subtitle: summaryCardsData[cardIndex]['subtitle'],
              cardBackgroundColor: cardBackgroundColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),
          ),
        );
        // Add spacing between cards in the same row (except for the last one)
        if (j < crossAxisCount - 1) {
          rowChildren.add(SizedBox(width: cardSpacing));
        }
      } else {
        // Add an empty Expanded to maintain alignment if the last row is not full
        rowChildren.add(Expanded(child: Container()));
        if (j < crossAxisCount - 1) {
          rowChildren.add(SizedBox(width: cardSpacing));
        }
      }
    }
    // Add the row to the list of rows
    rows.add(Row(children: rowChildren));
    // Add vertical spacing between rows (except for the last one)
    if (i + crossAxisCount < totalCards) {
      rows.add(SizedBox(height: cardSpacing));
    }
  }

  return Column(children: rows);
}
