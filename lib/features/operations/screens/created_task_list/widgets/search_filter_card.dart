import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFilterCard extends StatelessWidget {
  final TaskListController taskListController;
  final TextEditingController searchController;

  const SearchFilterCard({
    Key? key,
    required this.taskListController,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;

    return Card(
      elevation: 0,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with clear button
            Obx(() {
              // Keep the controller in sync with the observable
              if (searchController.text !=
                  taskListController.searchQuery.value) {
                searchController.text = taskListController.searchQuery.value;
                searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: searchController.text.length),
                );
              }

              return TextField(
                controller: searchController,
                onTapOutside:
                    (event) => FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                  hintText: 'Search tasks, clients, file no...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      taskListController.searchQuery.value.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              taskListController.updateSearch('');
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: taskListController.updateSearch,
              );
            }),

            const SizedBox(height: 16),

            // Filter options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by:',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(
                  () => _buildFilterChip(
                    'All',
                    'all',
                    taskListController,
                    Icons.list_alt,
                    taskListController.totalTasksCount,
                    AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Grid of filter chips
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Allotted',
                      'allotted',
                      taskListController,
                      Icons.assignment_outlined,
                      taskListController.totalAllotted.value,
                      Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Completed',
                      'completed',
                      taskListController,
                      Icons.check_circle_outline,
                      taskListController.totalCompleted.value,
                      Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Awaiting',
                      'awaiting',
                      taskListController,
                      Icons.hourglass_empty,
                      taskListController.totalAwaiting.value,
                      Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Re-allotted',
                      'reallotted',
                      taskListController,
                      Icons.replay_outlined,
                      taskListController.totalReallotted.value,
                      Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sort options
            Text(
              'Sort by:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Date', 'date', taskListController),
                  const SizedBox(width: 8),
                  _buildSortChip('Task Name', 'name', taskListController),
                  const SizedBox(width: 8),
                  _buildSortChip('Client', 'client', taskListController),
                  const SizedBox(width: 8),
                  _buildSortChip('Priority', 'priority', taskListController),
                  const SizedBox(width: 8),
                  _buildSortChip('Status', 'status', taskListController),
                ],
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    TaskListController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    return Obx(
      () => FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  controller.activeFilters.contains(value) ||
                          value == 'all' && controller.activeFilters.isEmpty
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(label),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        selected:
            value == 'all'
                ? controller.activeFilters.isEmpty
                : controller.activeFilters.contains(value),
        onSelected: (_) => controller.updateFilter(value),
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color:
              controller.activeFilters.contains(value) ||
                      value == 'all' && controller.activeFilters.isEmpty
                  ? AppColors.primary
                  : AppColors.textPrimary,
          fontWeight:
              controller.activeFilters.contains(value) ||
                      value == 'all' && controller.activeFilters.isEmpty
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                controller.activeFilters.contains(value) ||
                        value == 'all' && controller.activeFilters.isEmpty
                    ? AppColors.primary
                    : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterCard(
    String label,
    String value,
    TaskListController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    return Obx(() {
      final isSelected =
          value == 'all'
              ? controller.activeFilters.isEmpty
              : controller.activeFilters.contains(value);

      return GestureDetector(
        onTap: () => controller.updateFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row with label and count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? color : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Icon indicator
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSortChip(
    String label,
    String value,
    TaskListController controller,
  ) {
    return Obx(
      () => FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (controller.sortBy.value == value) ...[
              const SizedBox(width: 4),
              Icon(
                controller.sortAscending.value
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
              ),
            ],
          ],
        ),
        selected: controller.sortBy.value == value,
        onSelected: (_) => controller.updateSort(value),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color:
              controller.sortBy.value == value
                  ? AppColors.primary
                  : AppColors.textPrimary,
          fontWeight:
              controller.sortBy.value == value
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
