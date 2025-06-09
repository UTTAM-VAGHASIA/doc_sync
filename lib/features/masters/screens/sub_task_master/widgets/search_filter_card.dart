// Sub Task Master Search Filter Card Widget
// TODO: Implement Sub Task Master Search Filter Card 

import 'package:doc_sync/features/masters/controllers/sub_task_master_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterCard extends StatelessWidget {
  final SubTaskMasterListController subTaskMasterListController;
  final TextEditingController searchController;

  const SearchFilterCard({
    super.key,
    required this.subTaskMasterListController,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Search Bar with clear button
            Expanded(
              child: Obx(() {
                // Keep the controller in sync with the observable
                if (searchController.text != subTaskMasterListController.searchQuery.value) {
                  searchController.text = subTaskMasterListController.searchQuery.value;
                  searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: searchController.text.length),
                  );
                }

                return TextField(
                  controller: searchController,
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    hintText: 'Search sub tasks...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: subTaskMasterListController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              subTaskMasterListController.updateSearch('');
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
                  onChanged: subTaskMasterListController.updateSearch,
                );
              }),
            ),
            
            const SizedBox(width: 12),
            
            // Filter Button
            Obx(() => Badge(
              isLabelVisible: subTaskMasterListController.activeFilters.isNotEmpty,
              label: Text(subTaskMasterListController.activeFilters.length.toString()),
              backgroundColor: AppColors.primary,
              child: IconButton(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Iconsax.filter),
                tooltip: 'Filter',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: AppColors.primary,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  // Function to show filter options in a bottom sheet
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useSafeArea: true,
      isDismissible: true,
      constraints: null,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _FilterBottomSheet(subTaskMasterListController: subTaskMasterListController),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final SubTaskMasterListController subTaskMasterListController;

  const _FilterBottomSheet({required this.subTaskMasterListController});

  // Handle reset without closing the bottom sheet
  void _handleReset() {
    if (subTaskMasterListController.activeFilters.isNotEmpty) {
      subTaskMasterListController.activeFilters.clear();
      subTaskMasterListController.updateFilter('all');
    }
    
    // Reset sort to 'all'
    if (subTaskMasterListController.sortBy.value != 'all') {
      subTaskMasterListController.sortBy.value = 'all';
      subTaskMasterListController.sortAscending.value = true;
    }
    
    // Make sure the UI updates
    subTaskMasterListController.currentPage.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Options',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      // Reset filters button - made more responsive with direct call
                      Obx(() {
                        final hasActiveFilters = subTaskMasterListController.activeFilters.isNotEmpty;
                        final isNotDefaultSort = subTaskMasterListController.sortBy.value != 'all';
                        
                        return hasActiveFilters || isNotDefaultSort
                          ? TextButton.icon(
                              onPressed: _handleReset,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Reset'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                              ),
                            )
                          : const SizedBox.shrink();
                      }),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // Filter options content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter by Status
                  const SizedBox(height: 8),
                  _buildSectionHeader(context, 'Filter by Status'),
                  const SizedBox(height: 12),
                  
                  // All filter - full width
                  Obx(
                    () => _buildFullWidthFilterCard(
                      'All Sub Tasks',
                      'all',
                      subTaskMasterListController,
                      Iconsax.task_square,
                      subTaskMasterListController.totalSubTaskMastersCount,
                      AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 12),

                  // Status filter chips
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _buildStatusFilterCard(
                            'Enabled',
                            'enable',
                            subTaskMasterListController,
                            Iconsax.tick_circle,
                            subTaskMasterListController.totalEnabledSubTaskMasters.value,
                            Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusFilterCard(
                            'Disabled',
                            'disable',
                            subTaskMasterListController,
                            Iconsax.close_circle,
                            subTaskMasterListController.totalDisabledSubTaskMasters.value,
                            Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sort options
                  _buildSectionHeader(context, 'Sort by'),
                  const SizedBox(height: 12),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortChip('All', 'all', subTaskMasterListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Task Name', 'task_name', subTaskMasterListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Sub Task', 'sub_task_name', subTaskMasterListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Amount', 'amount', subTaskMasterListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Date', 'date_time', subTaskMasterListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Status', 'status', subTaskMasterListController),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  // Full-width filter card for All
  Widget _buildFullWidthFilterCard(
    String label,
    String value,
    SubTaskMasterListController controller,
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
    SubTaskMasterListController controller,
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
              const SizedBox(height: 4),
              // Icon indicator
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : AppColors.textSecondary,
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
    SubTaskMasterListController controller
  ) {
    return Obx(() {
      final isSelected = controller.sortBy.value == value;
      final isAscending = controller.sortAscending.value;
      
      return FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: isSelected 
            ? Icon(
                isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: AppColors.white,
              )
            : null,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppColors.primary,
        onSelected: (selected) {
          controller.updateSort(value);
        },
      );
    });
  }
} 