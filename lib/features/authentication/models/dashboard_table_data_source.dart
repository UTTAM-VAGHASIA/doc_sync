import 'package:data_table_2/data_table_2.dart';
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';

class DashboardTableData extends DataTableSource {
  final dashboardController = DashboardController.instance;

  @override
  DataRow? getRow(int index) {
    final data = dashboardController.tableItems[index];

    return DataRow2(
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(data.name.toString())),
        DataCell(Text(data.pending.toString())),
        DataCell(Text(data.completed.toString())),
        DataCell(Text(data.alloted.toString())),
        DataCell(Text(data.reAlloted.toString())),
        DataCell(Text(data.awaitingClient.toString())),
        DataCell(
          Text(
            ((data.pending ?? 0) +
                    (data.alloted ?? 0) +
                    (data.reAlloted ?? 0) +
                    (data.awaitingClient ?? 0))
                .toString(),
          ),
        ),
        DataCell(
          Text(
            ((data.pending ?? 0) +
                    (data.completed ?? 0) +
                    (data.alloted ?? 0) +
                    (data.reAlloted ?? 0) +
                    (data.awaitingClient ?? 0))
                .toString(),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => dashboardController.tableItems.length;

  @override
  int get selectedRowCount => 0;
}