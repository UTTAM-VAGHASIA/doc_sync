import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TaskDetailsSection extends StatelessWidget {
  const TaskDetailsSection({super.key, required this.controller});

  final NewTaskController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Task Instructions TextField
            _buildTaskInstructionsField(context),

            const SizedBox(height: 20),

            // Date Selection Row
            _buildDateSelectionRow(context),

            const SizedBox(height: 20),

            // Priority Dropdown (now on its own line)
            _buildPriorityDropdown(context),

            const SizedBox(height: 20),

            // Admin Verification Checkbox (now on its own line)
            _buildAdminVerificationCheckbox(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskInstructionsField(BuildContext context) {
    // Create a controller instance that persists between rebuilds
    final textController = TextEditingController(
      text: controller.taskInstructions.value,
    );

    return Obx(() {
      // Only update the text if it differs from the controller's text
      if (textController.text != controller.taskInstructions.value) {
        final previousCursor = textController.selection;
        textController.text = controller.taskInstructions.value;

        // Try to maintain the cursor position if possible
        if (previousCursor.start <= textController.text.length) {
          textController.selection = previousCursor;
        }
      }

      return TextFormField(
        controller: textController,
        maxLines: 4,
        onTapOutside: (value) {
          FocusScope.of(context).unfocus();
        },
        onTap: () {
          // Mark that user is now actively editing
          controller.isTaskInstructionsBeingEdited.value = true;
        },
        decoration: InputDecoration(
          labelText: 'Task Instructions',
          hintText: 'Enter detailed instructions for this task...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(Iconsax.document_text, color: AppColors.textSecondary),
          ),
          alignLabelWithHint: true,
          filled: true,
          fillColor: Colors.grey[50],
          helperText:
              'Instructions will be auto-populated as you select fields',
          helperMaxLines: 2,
        ),
        onChanged: (value) {
          if (!controller.isUpdatingInstructions.value) {
            controller.taskInstructions.value = value;
            // Store the current cursor position for next rebuild
            controller.cursorPosition.value = textController.selection;
          }
        },
      );
    });
  }

  Widget _buildDateSelectionRow(BuildContext context) {
    return Row(
      children: [
        // Allotted Date
        Expanded(
          child: Obx(
            () => _buildDatePicker(
              context: context,
              label: 'Allotted Date',
              selectedDate: controller.allottedDate.value,
              onDateSelected: (newDate) {
                if (newDate != null) {
                  controller.allottedDate.value = newDate;
                }
              },
              icon: Iconsax.calendar_1,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Expected End Date
        Expanded(
          child: Obx(
            () => _buildDatePicker(
              context: context,
              label: 'Expected End Date',
              selectedDate: controller.expectedEndDate.value,
              onDateSelected: (newDate) {
                if (newDate != null) {
                  controller.expectedEndDate.value = newDate;
                }
              },
              icon: Iconsax.calendar_tick,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required DateTime selectedDate,
    required Function(DateTime?) onDateSelected,
    required IconData icon,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );

        onDateSelected(pickedDate);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          prefixIcon: Icon(icon),
        ),
        child: Text(
          dateFormat.format(selectedDate),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    final priorityItems = ['High', 'Medium', 'Low'];

    return Obx(() {
      return SearchableDropdown<String>(
        label: 'Priority',
        hint: 'Select priority',
        items: priorityItems,
        value: controller.priority.value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            controller.priority.value = newValue;
          }
        },
        getLabel: (String priority) => priority,
        prefixIcon: Icon(
          Iconsax.ranking,
          color: _getPriorityColor(controller.priority.value),
        ),
      );
    });
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildAdminVerificationCheckbox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: controller.adminVerification.value,
                onChanged: (bool? value) {
                  controller.adminVerification.value = value ?? false;
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: AppColors.primary,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Admin Verification Required',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
