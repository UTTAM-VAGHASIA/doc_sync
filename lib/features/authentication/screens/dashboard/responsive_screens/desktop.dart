import 'package:data_table_2/data_table_2.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class DashboardDesktopScreen extends StatelessWidget {
  const DashboardDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a primary color similar to the image, adjust as needed
    final Color primaryColor = AppColors.primary;
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    final List<Map<String, dynamic>> summaryCardsData = [
      {
        'title': 'Tasks Created',
        'value': '0',
        'icon': Icons.list_alt_outlined,
        'iconColor': Colors.blue,
        'subtitle': 'Today',
      },
      {
        'title': 'Tasks Completed',
        'value': '0',
        'icon': Icons.check_circle_outline,
        'iconColor': Colors.green,
        'subtitle': 'Today',
      },
      {
        'title': 'Pending (Today)',
        'value': '0',
        'icon': Icons.pending_actions_outlined,
        'iconColor': Colors.orange,
        'subtitle': 'Today (Pending + Allotted + Re-Allotted)',
      },
      {
        'title': 'Pending (Total)',
        'value': '30',
        'icon': Icons.hourglass_top_outlined,
        'iconColor': Colors.redAccent,
        'subtitle': '(Total Pending + Allotted + Re-Allotted)',
      },
      {
        'title': 'High Priority',
        'value': '4',
        'icon': Icons.priority_high_rounded,
        'iconColor': Colors.red,
        'subtitle': '(Total Pending + Allotted + Re-Allotted)',
      },
      {
        'title': 'Running Late',
        'value': '30',
        'icon': Icons.running_with_errors_outlined,
        'iconColor': Colors.deepOrange,
        'subtitle': '(Total Pending + Allotted + Re-Allotted)',
      },
      // Add more cards if needed
    ];

    return Expanded(
      child: SingleChildScrollView(
        hitTestBehavior: HitTestBehavior.opaque,
        padding: const EdgeInsets.all(24.0), // Overall padding for the content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Summary Cards ---
            // --- Responsive Summary Card Grid ---
            _buildResponsiveCardGrid(
              context: context,
              cardsData: summaryCardsData,
              crossAxisCount: 3,
              cardBackgroundColor: cardBackgroundColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),

            const SizedBox(height: 30), // Spacing between cards and table
            // --- Work Flow Table Section ---
            Card(
              elevation: 2,
              shadowColor: Colors.grey.shade50,
              color: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header Row (Title, Entries, Search)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Work Flow | Over-all',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Flexible(
                          // Use Flexible to prevent overflow
                          child: Row(
                            mainAxisSize:
                                MainAxisSize.min, // Take minimum space
                            children: [
                              // Entries per page (Placeholder - Can be Dropdown)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '10 entries per page',
                                ), // Replace with DropdownButton later
                              ),
                              const SizedBox(width: 10),
                              // Search Bar
                              SizedBox(
                                width: 200, // Adjust width as needed
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 0,
                                    ), // Adjust padding
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- Data Table ---
                    SizedBox(
                      height:
                          450, // Define a height for the DataTable container
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        minWidth:
                            900, // Minimum width before horizontal scroll appears
                        columns: const [
                          DataColumn2(
                            label: Text('Sr. No.'),
                            size: ColumnSize.S,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Emp Name'),
                            size: ColumnSize.M,
                          ),
                          DataColumn2(
                            label: Text('Pending Tasks'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Completed Tasks'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Allotted Tasks'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Re-Allotted Tasks'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Awaiting Client'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Total Remaining'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                          DataColumn2(
                            label: Text('Total Tasks'),
                            size: ColumnSize.M,
                            numeric: true,
                          ),
                        ],
                        rows: List<DataRow>.generate(
                          9, // Number of dummy rows matching the image
                          (index) => DataRow(
                            cells: _getDummyRowCells(
                              index + 1,
                            ), // Use helper for dummy data
                          ),
                        ),
                        // Styling options (optional)
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade100,
                        ),
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        dataTextStyle: TextStyle(color: subtleTextColor),
                        border: TableBorder.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        dividerThickness: 1, // Use default thickness
                        showBottomBorder: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // --- Pagination Info ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing 1 to 9 of 9 entries', // Update dynamically later
                          style: TextStyle(
                            color: subtleTextColor,
                            fontSize: 13,
                          ),
                        ),
                        // Add Pagination controls here if needed (e.g., Prev/Next buttons)
                        // Example:
                        // Row(
                        //   children: [
                        //     TextButton(
                        //       onPressed: () {},
                        //       child: Text('Previous'),
                        //     ),
                        //     Text('1'), // Current page number
                        //     TextButton(onPressed: () {}, child: Text('Next')),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Summary Cards
  Widget _buildResponsiveCardGrid({
    required BuildContext context,
    required List<Map<String, dynamic>> cardsData,
    required int crossAxisCount,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
    double cardSpacing = 16.0, // Spacing between cards
  }) {
    List<Widget> rows = [];
    int totalCards = cardsData.length;

    for (int i = 0; i < totalCards; i += crossAxisCount) {
      List<Widget> rowChildren = [];
      for (int j = 0; j < crossAxisCount; j++) {
        int cardIndex = i + j;
        if (cardIndex < totalCards) {
          // Add Expanded Card
          rowChildren.add(
            Expanded(
              child: _buildSummaryCard(
                context: context,
                title: cardsData[cardIndex]['title'],
                value: cardsData[cardIndex]['value'],
                icon: cardsData[cardIndex]['icon'],
                iconColor: cardsData[cardIndex]['iconColor'],
                subtitle: cardsData[cardIndex]['subtitle'],
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

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.shade50,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        // REMOVED: width: 260, - Expanded will handle the width now
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Important for height within Expanded
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // Allow text to wrap if needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: subtleTextColor),
                            maxLines: 2, // Allow subtitle to wrap
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Give Icon some padding if text is long and wraps near it
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(icon, size: 30, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to generate dummy data cells for a row
  List<DataCell> _getDummyRowCells(int rowIndex) {
    // Sample data structure based on the image
    final data = [
      [1, 'Staff1', 1, 11, 7, 1, 0, 9, 20],
      [2, 'staff2', 0, 88, 3, 0, 3, 6, 94],
      [3, 'staff3', 0, 102, 3, 0, 2, 5, 107],
      [4, 'staff4', 0, 52, 1, 0, 0, 1, 53],
      [5, 'staff5', 1, 43, 0, 0, 0, 1, 44],
      [6, 'staff6', 0, 2, 2, 0, 0, 2, 4],
      [7, 'staff7', 0, 63, 3, 0, 0, 3, 66],
      [8, 'staff8', 3, 84, 0, 0, 0, 3, 87],
      [
        9,
        'staff9',
        0,
        31,
        0,
        0,
        0,
        0,
        31,
      ], // Adjusted last row based on image data
    ];

    // Get the data for the current row index (adjusting for 0-based index)
    var rowData = data[rowIndex - 1];

    // Create DataCells, converting numbers to strings
    return rowData
        .map((cellData) => DataCell(Text(cellData.toString())))
        .toList();
  }
}
