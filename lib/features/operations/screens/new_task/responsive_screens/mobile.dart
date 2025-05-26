import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/client_selection_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/financial_year_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/staff_allotment_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/task_details_section.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/task_selection_section.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';

class NewTaskMobileScreen extends StatelessWidget {
  const NewTaskMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewTaskController>();

    return LiquidPullToRefresh(
      key: controller.refreshIndicatorKey,
      onRefresh: () async {
        controller.loadData();
      },
      showChildOpacityTransition: false,
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      height: 100,
      child: Container(
        color: AppColors.lightGrey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RouteHeader(
                title: 'Create New Task',
                subtitle: 'Home / Task Creation / Add-Data',
              ),

              // Task and Subtask Selection
              TaskSelectionSection(controller: controller),

              // Client Selection
              ClientSelectionSection(controller: controller),

              // Staff Allotment
              StaffAllotmentSection(controller: controller),

              // Financial Year Selection
              FinancialYearSection(controller: controller),

              // Task Details Section (Task Instructions, Dates, Priority)
              TaskDetailsSection(controller: controller),

              // Action Buttons Section
              const SizedBox(height: 32),

              // Primary Action - Submit Task Button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () =>
                      controller.isSubmitting.value
                          ? AppShimmerEffect(
                            height: 56,
                            width: double.infinity,
                            radius: 12,
                          )
                          : ElevatedButton.icon(
                            onPressed: () => controller.submitNewTask(),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(
                              'Submit Task',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                ),
              ),

              const SizedBox(height: 16),

              // Secondary Actions Row
              Row(
                children: [
                  // Save Draft Button
                  Expanded(
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed:
                            controller.isSubmitting.value
                                ? null
                                : () => controller.saveDraft(),
                        icon: const Icon(Icons.save_outlined, size: 20),
                        label: const Text('Save Draft'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Load Draft Button
                  Expanded(
                    child: Obx(
                      () => ElevatedButton.icon(
                        onPressed:
                            controller.isSubmitting.value
                                ? null
                                : () => controller.loadDraft(),
                        icon: const Icon(Icons.restore, size: 20),
                        label: const Text('Load Draft'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: AppColors.secondary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Clear Form and Clear Draft Buttons (Tertiary Actions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Obx(
                      () => TextButton.icon(
                        onPressed:
                            controller.isSubmitting.value
                                ? null
                                : () => controller.clearForm(),
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear Form'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => TextButton.icon(
                        onPressed:
                            controller.isSubmitting.value
                                ? null
                                : () => controller.clearDraft(),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Clear Draft'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.black54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
