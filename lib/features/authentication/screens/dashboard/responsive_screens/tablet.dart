import 'package:data_table_2/data_table_2.dart';
import 'package:doc_sync/common/widgets/data_table/paginated_data_table.dart';
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/models/dashboard_table_data_source.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/widgets/responsive_card_grid.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class DashboardTabletScreen extends StatelessWidget {
  const DashboardTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = DashboardController.instance;
    // Using a primary color similar to the image, adjust as needed
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    return LiquidPullToRefresh(
      animSpeedFactor: 2.3,
      color: AppColors.primary,
      backgroundColor: AppColors.light,
      showChildOpacityTransition: false,
      onRefresh: () => dashboardController.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        // hitTestBehavior: HitTestBehavior.opaque,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Greeting and route info ---
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          'Welcome, ${dashboardController.userController.user.value.name}!',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'home / dashboard',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: subtleTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  // Optionally, add an avatar or icon here for extra polish
                ],
              ),
            ),
            // --- Top Summary Cards ---
            // --- Responsive Summary Card Grid ---
            Obx(
              () => buildResponsiveCardGrid(
                context: context,
                cardsData: [
                  dashboardController.todayCreated.value,
                  dashboardController.todayCompleted.value,
                  dashboardController.todayPending.value,
                  dashboardController.totalPending.value,
                  dashboardController.totalTasks.value,
                  dashboardController.runningLate.value,
                ],
                crossAxisCount: 2,
                cardBackgroundColor: cardBackgroundColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ),

            const SizedBox(height: 30), // Spacing between cards and table
            // --- Work Flow Table Section ---
            // Card(
            //   elevation: 2,
            //   shadowColor: Colors.grey.shade50,
            //   color: cardBackgroundColor,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(16.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         // Table Header Row (Title, Entries, Search)
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text(
            //               'Work Flow | Over-all',
            //               style: Theme.of(
            //                 context,
            //               ).textTheme.titleLarge?.copyWith(
            //                 fontWeight: FontWeight.w600,
            //                 color: textColor,
            //               ),
            //             ),
            //             Flexible(
            //               // Use Flexible to prevent overflow
            //               child: Row(
            //                 mainAxisSize:
            //                     MainAxisSize.min, // Take minimum space
            //                 children: [
            //                   // Entries per page (Placeholder - Can be Dropdown)
            //                   Container(
            //                     padding: const EdgeInsets.symmetric(
            //                       horizontal: 8,
            //                       vertical: 4,
            //                     ),
            //                     decoration: BoxDecoration(
            //                       border: Border.all(
            //                         color: Colors.grey.shade300,
            //                       ),
            //                       borderRadius: BorderRadius.circular(4),
            //                     ),
            //                     child: const Text(
            //                       '10 entries per page',
            //                     ), // Replace with DropdownButton later
            //                   ),
            //                   const SizedBox(width: 10),
            //                   // Search Bar
            //                   SizedBox(
            //                     width: 200, // Adjust width as needed
            //                     child: TextField(
            //                       decoration: InputDecoration(
            //                         hintText: 'Search...',
            //                         prefixIcon: const Icon(
            //                           Icons.search,
            //                           size: 18,
            //                         ),
            //                         border: OutlineInputBorder(
            //                           borderRadius: BorderRadius.circular(8),
            //                           borderSide: BorderSide(
            //                             color: Colors.grey.shade300,
            //                           ),
            //                         ),
            //                         contentPadding: const EdgeInsets.symmetric(
            //                           horizontal: 10,
            //                           vertical: 0,
            //                         ), // Adjust padding
            //                         isDense: true,
            //                       ),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //         const SizedBox(height: 16),

            //         // --- Data Table ---
            //         SizedBox(
            //           height:
            //               450, // Define a height for the DataTable container
            //           child: DataTable2(
            //             columnSpacing: 12,
            //             horizontalMargin: 12,
            //             minWidth:
            //                 900, // Minimum width before horizontal scroll appears
            //             columns: const [
            //               DataColumn2(
            //                 label: Text('Sr. No.'),
            //                 size: ColumnSize.S,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Emp Name'),
            //                 size: ColumnSize.M,
            //               ),
            //               DataColumn2(
            //                 label: Text('Pending Tasks'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Completed Tasks'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Allotted Tasks'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Re-Allotted Tasks'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Awaiting Client'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Total Remaining'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //               DataColumn2(
            //                 label: Text('Total Tasks'),
            //                 size: ColumnSize.M,
            //                 numeric: true,
            //               ),
            //             ],
            //             rows: List<DataRow>.generate(
            //               9, // Number of dummy rows matching the image
            //               (index) => DataRow(
            //                 cells: _getDummyRowCells(
            //                   index + 1,
            //                 ), // Use helper for dummy data
            //               ),
            //             ),
            //             // Styling options (optional)
            //             headingRowColor: WidgetStateProperty.all(
            //               Colors.grey.shade100,
            //             ),
            //             headingTextStyle: TextStyle(
            //               fontWeight: FontWeight.bold,
            //               color: textColor,
            //             ),
            //             dataTextStyle: TextStyle(color: subtleTextColor),
            //             border: TableBorder.all(
            //               color: Colors.grey.shade300,
            //               width: 1,
            //             ),
            //             dividerThickness: 1, // Use default thickness
            //             showBottomBorder: true,
            //           ),
            //         ),
            //         const SizedBox(height: 16),
            //         // --- Pagination Info ---
            //         Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           children: [
            //             Text(
            //               'Showing 1 to 9 of 9 entries', // Update dynamically later
            //               style: TextStyle(
            //                 color: subtleTextColor,
            //                 fontSize: 13,
            //               ),
            //             ),
            //             // Add Pagination controls here if needed (e.g., Prev/Next buttons)
            //             // Example:
            //             // Row(
            //             //   children: [
            //             //     TextButton(
            //             //       onPressed: () {},
            //             //       child: Text('Previous'),
            //             //     ),
            //             //     Text('1'), // Current page number
            //             //     TextButton(onPressed: () {}, child: Text('Next')),
            //             //   ],
            //             // ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

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
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppPaginatedDataTable(
                      tableHeight: 600,
                      sortAscending: true,
                      columns: const [
                        DataColumn2(label: Text('Sr.\nNo.')),
                        DataColumn2(label: Text('Emp\nName')),
                        DataColumn2(label: Text('Pending\nTasks')),
                        DataColumn2(label: Text('Completed\nTasks')),
                        DataColumn2(label: Text('Alloted\nTasks')),
                        DataColumn2(label: Text('Re-Alloted\nTasks')),
                        DataColumn2(label: Text('Awaiting\nClient')),
                        DataColumn2(label: Text('Total\nRemaining')),
                        DataColumn2(label: Text('Total\nTasks')),
                      ],
                      source: DashboardTableData(),
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
}
