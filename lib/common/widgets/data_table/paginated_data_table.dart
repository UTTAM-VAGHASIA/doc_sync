import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../loaders/animation_loader.dart';

/// Custom PaginatedDataTable widget with additional features
class AppPaginatedDataTable extends StatelessWidget {
  const AppPaginatedDataTable({
    super.key,
    required this.columns,
    required this.source,
    this.rowsPerPage = 25,
    this.availableRowsPerPage = const [5, 10, 15, 20, 25],
    this.tableHeight = 760,
    this.onPageChanged,
    this.sortColumnIndex,
    this.dataRowHeight = AppSizes.xl * 2,
    this.sortAscending = true,
    this.minWidth = 900,
  });

  /// Whether to sort the DataTable in ascending or descending order.
  final bool sortAscending;

  /// Index of the column to sort by.
  final int? sortColumnIndex;

  /// Number of rows to display per page.
  final int rowsPerPage;

  /// List of available rows per page options.
  final List<int> availableRowsPerPage;

  /// Data source for the DataTable.
  final DataTableSource source;

  /// List of columns for the DataTable.
  final List<DataColumn> columns;

  /// Callback function to handle page changes.
  final Function(int)? onPageChanged;

  /// Height of each data row in the DataTable.
  final double dataRowHeight;

  /// Height of the entire DataTable.
  final double tableHeight;

  /// Minimum Width of the entire DataTable.
  final double? minWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Set the dynamic height of the PaginatedDataTable
      height: tableHeight,
      child: Theme(
        // Use to set the Backend color
        data: Theme.of(context).copyWith(
          cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
        ),
        child: PaginatedDataTable2(
          source: source,
          columns: columns,
          columnSpacing: 12,
          minWidth: minWidth,
          dividerThickness: 1,
          horizontalMargin: 12,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: availableRowsPerPage,
          showFirstLastButtons: true,
          showCheckboxColumn: true,
          sortAscending: sortAscending,
          onPageChanged: onPageChanged,
          dataRowHeight: dataRowHeight,
          renderEmptyRowsInTheEnd: false,
          border: TableBorder.all(color: Colors.grey.shade300, width: 1),
          onRowsPerPageChanged: (noOfRows) {},
          sortColumnIndex: sortColumnIndex,
          headingTextStyle: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: AppColors.textWhite),
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => AppColors.primary,
          ),
          empty: AppAnimationLoaderWidget(
            animation: AppImages.packageAnimation,
            text: 'Nothing Found',
            height: 200,
            width: 200,
          ),
          headingRowDecoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSizes.borderRadiusMd),
              topRight: Radius.circular(AppSizes.borderRadiusMd),
            ),
          ),
          sortArrowBuilder: (bool ascending, bool sorted) {
            if (sorted) {
              return Icon(
                ascending ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                size: AppSizes.iconSm,
              );
            } else {
              return const Icon(Iconsax.arrow_3, size: AppSizes.iconSm);
            }
          },
        ),
      ),
    );
  }
}
