import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginationControls extends StatelessWidget {
  final ClientListController controller;
  final Color cardBackgroundColor;
  final Color textColor;

  const PaginationControls({
    Key? key,
    required this.controller,
    required this.cardBackgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cardBackgroundColor,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Items per page selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show', style: TextStyle(color: textColor)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                      value: controller.itemsPerPage,
                      underline: const SizedBox(),
                      items:
                          [5, 10, 15, 20].map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.itemsPerPage = value;
                        }
                      },
                    ),
                ),
                const SizedBox(width: 8),
                Text('entries', style: TextStyle(color: textColor)),
              ],
            ),
            const SizedBox(height: 16),
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        controller.currentPage.value > 0
                            ? controller.previousPage
                            : null,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          controller.currentPage.value > 0
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => Text(
                    'Page ${controller.currentPage.value + 1} of ${controller.totalPages}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        controller.currentPage.value < controller.totalPages - 1
                            ? controller.nextPage
                            : null,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          controller.currentPage.value <
                                  controller.totalPages - 1
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade200,
                    ),
                  ),
                ),
              ],
            ),
            // Page info
            Obx(() {
              final start =
                  controller.currentPage.value * controller.itemsPerPage +
                  (controller.filteredClients.isEmpty ? 0 : 1);
              final end = start + controller.paginatedClients.length - 
                  (controller.filteredClients.isEmpty ? 0 : 1);
              final total = controller.filteredClients.length;

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  controller.filteredClients.isEmpty 
                      ? 'No entries to show' 
                      : 'Showing $start to $end of $total entries',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
} 