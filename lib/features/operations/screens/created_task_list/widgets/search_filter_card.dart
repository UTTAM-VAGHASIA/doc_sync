import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterCard extends StatelessWidget {
  final TaskListController taskListController;
  final TextEditingController searchController;

  const SearchFilterCard({
    super.key,
    required this.taskListController,
    required this.searchController,
  });

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

            // Filter by Status header
            Text(
              'Filter by Status:',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),
            
            // All filter - full width
            Obx(
              () => _buildFullWidthFilterCard(
                'All Tasks',
                'all',
                taskListController,
                Icons.list_alt,
                taskListController.totalTasksCount,
                AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 8),

            // Status filter chips - first row
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

            // Status filter chips - second row
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Client Waiting',
                      'client_waiting',
                      taskListController,
                      Icons.hourglass_empty,
                      taskListController.totalClientWaiting.value,
                      Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Re-allotted',
                      're_alloted',
                      taskListController,
                      Icons.replay_outlined,
                      taskListController.totalReallotted.value,
                      Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            
            // Status filter chips - third row with pending
            Obx(
              () => _buildStatusFilterCard(
                'Pending',
                'pending',
                taskListController,
                Icons.pending_outlined,
                taskListController.pendingCount.value,
                Colors.amber.shade700,
              ),
            ),

            const SizedBox(height: 16),

            // Allocation filter options
            Text(
              'Filter by Allocation:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            
            const SizedBox(height: 8),
            
            // Allotted by me filter
            Row(
              children: [
                Obx(
                  () => Expanded(
                    child: _buildStatusFilterCard(
                      'Allotted by me',
                      'allotted_by_me',
                      taskListController,
                      Icons.outgoing_mail,
                      taskListController.allottedByMeCount.value,
                      Colors.indigo.shade600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                
                // Allotted to me filter
                Obx(
                  () => Expanded(
                    child: _buildStatusFilterCard(
                      'Allotted to me',
                      'allotted_to_me',
                      taskListController,
                      Icons.inbox,
                      taskListController.allottedToMeCount.value,
                      Colors.teal.shade600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Priority filter options
            Text(
              'Filter by Priority:',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildPriorityFilterCard(
                      'High',
                      'high',
                      taskListController,
                      taskListController.highPriorityCount.value,
                      Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityFilterCard(
                      'Medium',
                      'medium',
                      taskListController,
                      taskListController.mediumPriorityCount.value,
                      Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityFilterCard(
                      'Low',
                      'low',
                      taskListController,
                      taskListController.lowPriorityCount.value,
                      Colors.green.shade600,
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
  
  // Full-width filter card for All
  Widget _buildFullWidthFilterCard(
    String label,
    String value,
    TaskListController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.activeFilters.isEmpty;
      return GestureDetector(
        onTap: () => controller.updateFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? color : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
      final isSelected = controller.activeFilters.contains(value);
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
            boxShadow: isSelected
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
      () {
        final isSelected = controller.sortBy.value == value;
        return ActionChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 4),
              if (isSelected)
                Icon(
                  controller.sortAscending.value
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 14,
                  color: AppColors.primary,
                ),
            ],
          ),
          backgroundColor:
              isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade100,
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onPressed: () => controller.updateSort(value),
        );
      },
    );
  }

  Widget _buildPriorityFilterCard(
    String label,
    String value,
    TaskListController controller,
    int count,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.activeFilters.contains(value);
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
            boxShadow: isSelected
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
              // Icon at top
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(isSelected ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Iconsax.ranking,
                      size: 16,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
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
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
