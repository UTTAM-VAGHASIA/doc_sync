import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/client_selection_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/financial_year_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/staff_allotment_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/task_details_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/task_selection_section.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class NewTaskDesktopScreen extends StatelessWidget {
  const NewTaskDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewTaskController>();

    return LiquidPullToRefresh(
      key: controller.refreshIndicatorKey,
      onRefresh: () async {
        controller.loadData();
      },
      showChildOpacityTransition: true,
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      height: 100,
      child: Container(
        color: AppColors.lightGrey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "Create New Task",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Two-column layout for desktop
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Task and Client selection
                  Expanded(
                    child: Column(
                      children: [
                        // Task Selection
                        TaskSelectionSection(controller: controller),

                        // Client Selection
                        ClientSelectionSection(controller: controller),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right column - Staff and Financial Year
                  Expanded(
                    child: Column(
                      children: [
                        // Staff Allotment
                        StaffAllotmentSection(controller: controller),

                        // Financial Year
                        FinancialYearSection(controller: controller),
                      ],
                    ),
                  ),
                ],
              ),

              // Task Details Section in full width
              TaskDetailsSection(controller: controller),

              // Submit Button - Full width at bottom
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 300,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed:
                          controller.isSubmitting.value
                              ? null
                              : () {
                                if (controller.validateForm()) {
                                  // Submit form
                                  // This will be implemented in future tasks
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          controller.isSubmitting.value
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline),
                                  SizedBox(width: 10),
                                  Text(
                                    'Submit Task',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
