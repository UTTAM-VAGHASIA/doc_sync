import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class DateSelectionCard extends StatelessWidget {
  final TaskListController taskListController;

  const DateSelectionCard({super.key, required this.taskListController});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white),
      ),
      child: InkWell(
        onTap: () => _selectDate(Get.context!, taskListController),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            taskListController.allotedDateStr.value.isEmpty
                                ? "No date selected"
                                : DateFormat("dd MMM, yyyy").format(
                                  DateTime.parse(
                                    taskListController.allotedDateStr.value,
                                  ),
                                ),
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  taskListController
                                          .allotedDateStr
                                          .value
                                          .isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildRefreshButton(taskListController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(TaskListController controller) {
    return OutlinedButton.icon(
      onPressed: () async {
        final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
            controller.refreshIndicatorKey;

        await controller.clearDate();

        if (refreshIndicatorKey.currentState != null) {
          await refreshIndicatorKey.currentState!.show();
        }
      },
      icon: const Icon(Icons.list_alt, size: 16),
      label: const Text('Show All'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    TaskListController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(
        (controller.allotedDateStr.value.isNotEmpty)
            ? controller.allotedDateStr.value
            : DateTime.now().toString(),
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
              surface: AppColors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Update the date first
      await controller.setAllotedDate(picked);

      // Then fetch tasks with refresh animation
      final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
          controller.refreshIndicatorKey;

      if (refreshIndicatorKey.currentState != null) {
        await refreshIndicatorKey.currentState!.show();
      }
    }
  }
}
