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

// Add these methods to your DashboardTableData class:

extension DashboardTableDataExtension on DashboardTableData {
  String getEmployeeName(int index) {
    // Assuming column 1 is the employee name
    return getCell(index, 1).toString();
  }

  int getPendingTasks(int index) {
    // Assuming column 2 is the pending tasks
    return int.parse(getCell(index, 2).toString());
  }

  int getCompletedTasks(int index) {
    // Assuming column 3 is the completed tasks
    return int.parse(getCell(index, 3).toString());
  }

  int getAllottedTasks(int index) {
    // Assuming column 4 is the allotted tasks
    return int.parse(getCell(index, 4).toString());
  }

  int getReAllottedTasks(int index) {
    // Assuming column 5 is the re-allotted tasks
    return int.parse(getCell(index, 5).toString());
  }

  int getAwaitingClient(int index) {
    // Assuming column 6 is the awaiting client
    return int.parse(getCell(index, 6).toString());
  }

  int getTotalRemaining(int index) {
    // Assuming column 7 is the total remaining
    return int.parse(getCell(index, 7).toString());
  }

  int getTotalTasks(int index) {
    // Assuming column 8 is the total tasks
    return int.parse(getCell(index, 8).toString());
  }

  // Helper method to get cell value at specific row and column
  dynamic getCell(int rowIndex, int columnIndex) {
    if (rowIndex < 0 || rowIndex >= dashboardController.tableItems.length) {
      return "";
    }

    final data = dashboardController.tableItems[rowIndex];

    // Map column index to the corresponding property
    switch (columnIndex) {
      case 0: // Serial number (index + 1)
        return rowIndex + 1;
      case 1: // Employee name
        return data.name;
      case 2: // Pending tasks
        return data.pending;
      case 3: // Completed tasks
        return data.completed;
      case 4: // Allotted tasks
        return data.alloted;
      case 5: // Re-allotted tasks
        return data.reAlloted;
      case 6: // Awaiting client
        return data.awaitingClient;
      case 7: // Total remaining
        return (data.pending ?? 0) +
            (data.alloted ?? 0) +
            (data.reAlloted ?? 0) +
            (data.awaitingClient ?? 0);
      case 8: // Total tasks
        return (data.pending ?? 0) +
            (data.completed ?? 0) +
            (data.alloted ?? 0) +
            (data.reAlloted ?? 0) +
            (data.awaitingClient ?? 0);
      default:
        return "";
    }
  }
}
