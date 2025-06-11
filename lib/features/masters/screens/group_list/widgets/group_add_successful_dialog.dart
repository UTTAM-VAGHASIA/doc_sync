import 'package:doc_sync/routes/routes.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupAddSuccessfulDialog extends StatelessWidget {
  const GroupAddSuccessfulDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.primary, size: 56),
            const SizedBox(height: 16),
            Text(
              'Group Added Successfully!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The group has been added successfully.\n\nWhat would you like to do next?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Group'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      Get.back(); // Close dialog, stay on form
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Group List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(AppRoutes.group); // Navigate to group list
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 