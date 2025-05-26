import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';
import 'package:doc_sync/features/operations/models/sub_task_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TaskSelectionSection extends StatelessWidget {
  const TaskSelectionSection({super.key, required this.controller});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task Selection',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Task Dropdown with add button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildTaskDropdown(context)),
                const SizedBox(width: 6),
                _buildAddButton(
                  context: context,
                  onTap: () => _showAddTaskDialog(context),
                  tooltip: 'Add new task',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sub-Task Dropdown with add button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildSubTaskDropdown(context)),
                const SizedBox(width: 6),
                Obx(
                  () => _buildAddButton(
                    context: context,
                    onTap:
                        controller.selectedTask.value != null
                            ? () => _showAddSubtaskDialog(context)
                            : null,
                    tooltip: 'Add new sub-task',
                    isDisabled: controller.selectedTask.value == null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required VoidCallback? onTap,
    required String tooltip,
    bool isDisabled = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Icon(
              Icons.add_circle_rounded,
              color: isDisabled ? Colors.grey[600] : AppColors.primary,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskDropdown(BuildContext context) {
    return Obx(() {
      return SearchableDropdown<Task>(
        label: 'Task',
        hint:
            controller.isLoadingTasks.value
                ? 'Loading tasks...'
                : 'Select a task',
        items: controller.tasks,
        value: controller.selectedTask.value,
        onChanged: (Task? newValue) {
          if (newValue?.taskId != controller.selectedTask.value?.taskId) {
            controller.selectedTask.value = newValue;
            controller.selectedSubTask.value = null;

            // Load subtasks for the selected task
            if (newValue != null) {
              controller.fetchSubTasksForTask(newValue.taskId);
            } else {
              controller.subTasks.clear();
            }
          }
        },
        getLabel: (Task task) => task.taskName,
        prefixIcon: const Icon(Iconsax.task_square),
        isLoading: controller.isLoadingTasks.value,
      );
    });
  }

  Widget _buildSubTaskDropdown(BuildContext context) {
    return Obx(() {
      final bool isTaskSelected = controller.selectedTask.value != null;

      return SearchableDropdown<SubTask>(
        label: 'Sub-Task',
        hint:
            !isTaskSelected
                ? 'Select a task first'
                : controller.isLoadingSubTasks.value
                ? 'Loading sub-tasks...'
                : 'Select a sub-task',
        items: controller.subTasks,
        value: controller.selectedSubTask.value,
        onChanged: (SubTask? newValue) {
          if (isTaskSelected) {
            controller.selectedSubTask.value = newValue;
          }
        },
        getLabel: (SubTask subTask) => subTask.subTaskName,
        prefixIcon: const Icon(Iconsax.task),
        isLoading: controller.isLoadingSubTasks.value,
        enabled: isTaskSelected,
      );
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController taskNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            title: const Text('Add New Task'),
            content: TextField(
              controller: taskNameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    controller.isLoadingTasks.value
                        ? null
                        : () {
                          Navigator.of(context).pop();
                        },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    controller.isLoadingTasks.value
                        ? null
                        : () async {
                          final String taskName =
                              taskNameController.text.trim();
                          if (taskName.isEmpty) {
                            AppLoaders.warningSnackBar(
                              title: 'Empty Field',
                              message: 'Please enter a task name',
                            );
                            return;
                          }
                          await controller.addTask(taskName);
                          if (!controller.isLoadingTasks.value && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                child:
                    controller.isLoadingTasks.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSubtaskDialog(BuildContext context) {
    final TextEditingController subtaskNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            title: const Text('Add New Sub-task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For task: ${controller.selectedTask.value?.taskName ?? "Unknown"}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subtaskNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Sub-task Name',
                    hintText: 'Enter sub-task name',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed:
                    controller.isLoadingSubTasks.value
                        ? null
                        : () {
                          Navigator.of(context).pop();
                        },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    controller.isLoadingSubTasks.value
                        ? null
                        : () async {
                          final String subtaskName =
                              subtaskNameController.text.trim();
                          if (subtaskName.isEmpty) {
                            AppLoaders.warningSnackBar(
                              title: 'Empty Field',
                              message: 'Please enter a sub-task name',
                            );
                            return;
                          }
                          await controller.addSubTask(subtaskName);
                          if (!controller.isLoadingSubTasks.value && context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                child:
                    controller.isLoadingSubTasks.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}