import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterCard extends StatelessWidget {
  final AdminVerificationController adminVerificationController;
  final TextEditingController searchController;

  const SearchFilterCard({
    super.key,
    required this.adminVerificationController,
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
                  adminVerificationController.searchQuery.value) {
                searchController.text = adminVerificationController.searchQuery.value;
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
                      adminVerificationController.searchQuery.value.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              adminVerificationController.updateSearch('');
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
                onChanged: adminVerificationController.updateSearch,
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
                adminVerificationController,
                Icons.list_alt,
                adminVerificationController.totalTasksCount,
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
                      adminVerificationController,
                      Icons.assignment_outlined,
                      adminVerificationController.totalAllotted,
                      Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Completed',
                      'completed',
                      adminVerificationController,
                      Icons.check_circle_outline,
                      adminVerificationController.totalCompleted,
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
                      adminVerificationController,
                      Icons.hourglass_empty,
                      adminVerificationController.totalClientWaiting,
                      Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Re-allotted',
                      're_alloted',
                      adminVerificationController,
                      Icons.replay_outlined,
                      adminVerificationController.totalReallotted,
                      Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            
            // Status filter chips - third row with pending centered
            Obx(
              () => _buildStatusFilterCard(
                'Pending',
                'pending',
                adminVerificationController,
                Icons.pending_outlined,
                adminVerificationController.pendingCount.value,
                Colors.amber.shade700,
              ),
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
                      adminVerificationController,
                      adminVerificationController.highPriorityCount.value,
                      Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityFilterCard(
                      'Medium',
                      'medium',
                      adminVerificationController,
                      adminVerificationController.mediumPriorityCount.value,
                      Colors.orange.shade600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPriorityFilterCard(
                      'Low',
                      'low',
                      adminVerificationController,
                      adminVerificationController.lowPriorityCount.value,
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
                  _buildSortChip('Date', 'date', adminVerificationController),
                  const SizedBox(width: 8),
                  _buildSortChip('Task Name', 'name', adminVerificationController),
                  const SizedBox(width: 8),
                  _buildSortChip('Client', 'client', adminVerificationController),
                  const SizedBox(width: 8),
                  _buildSortChip('Priority', 'priority', adminVerificationController),
                  const SizedBox(width: 8),
                  _buildSortChip('Status', 'status', adminVerificationController),
                ],
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
  
  // New widget for full-width filter card
  Widget _buildFullWidthFilterCard(
    String label,
    String value,
    AdminVerificationController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    return Obx(() {
      final isSelected = controller.activeFilters.contains(value);
      return GestureDetector(
        onTap: () => controller.updateFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha:0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha:0.2),
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
                  color: color.withValues(alpha:isSelected ? 0.2 : 0.1),
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
                  color: color.withValues(alpha:0.15),
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
    AdminVerificationController controller,
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
            color: isSelected ? color.withValues(alpha:0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha:0.2),
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
                      color: color.withValues(alpha:0.15),
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
                  color: color.withValues(alpha:isSelected ? 0.2 : 0.1),
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
    AdminVerificationController controller,
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
              isSelected ? AppColors.primary.withValues(alpha:0.1) : Colors.grey.shade100,
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
    AdminVerificationController controller,
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
            color: isSelected ? color.withValues(alpha:0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha:0.2),
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
              // Icon at top - SWAPPED position with text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha:isSelected ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Iconsax.ranking,
                      size: 16,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha:0.15),
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
              SizedBox(height: 6),
              // Bottom row with label and count - SWAPPED position with icon
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