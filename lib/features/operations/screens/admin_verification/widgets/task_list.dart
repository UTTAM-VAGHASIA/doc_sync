import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/task_card.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskList extends StatelessWidget {
  final AdminVerificationController adminVerificationController;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const TaskList({
    super.key,
    required this.adminVerificationController,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminVerificationController.paginatedTasks.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final task = adminVerificationController.paginatedTasks[index];
        return TaskExpansionCard(
          task: task,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        );
      },
    ));
  }
}

class EmptyTaskList extends StatelessWidget {
  const EmptyTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No tasks found with current filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter settings',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListShimmer extends StatelessWidget {
  const TaskListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: AppShimmerEffect(width: double.infinity, height: 80),
        );
      },
    );
  }
} 