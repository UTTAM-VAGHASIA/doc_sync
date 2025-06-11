import 'package:doc_sync/features/masters/controllers/financial_year_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterCard extends StatelessWidget {
  final FinancialYearListController financialYearListController;
  final TextEditingController searchController;

  const SearchFilterCard({
    super.key,
    required this.financialYearListController,
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
                if (searchController.text != financialYearListController.searchQuery.value) {
                  searchController.text = financialYearListController.searchQuery.value;
                  searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: searchController.text.length),
                  );
                }

                return TextField(
                  controller: searchController,
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    hintText: 'Search financial years...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: financialYearListController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              financialYearListController.updateSearch('');
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
                  onChanged: financialYearListController.updateSearch,
                );
              }),
            ),
            
            const SizedBox(width: 12),
            
            // Filter Button
            Obx(() => Badge(
              isLabelVisible: financialYearListController.activeFilters.isNotEmpty,
              label: Text(financialYearListController.activeFilters.length.toString()),
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
        child: _FilterBottomSheet(financialYearListController: financialYearListController),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final FinancialYearListController financialYearListController;

  const _FilterBottomSheet({required this.financialYearListController});

  // Handle reset without closing the bottom sheet
  void _handleReset() {
    if (financialYearListController.activeFilters.isNotEmpty) {
      financialYearListController.activeFilters.clear();
      financialYearListController.updateFilter('all');
    }
    
    // Reset sort to 'all'
    if (financialYearListController.sortBy.value != 'all') {
      financialYearListController.sortBy.value = 'all';
      financialYearListController.sortAscending.value = true;
    }
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
                      // Reset filters button
                      Obx(() {
                        final hasActiveFilters = financialYearListController.activeFilters.isNotEmpty;
                        final isNotDefaultSort = financialYearListController.sortBy.value != 'all';
                        
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
                  // Sort options
                  _buildSectionHeader(context, 'Sort by'),
                  const SizedBox(height: 12),
                  
                  // Sort options - Horizontal Chips like client list
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSortChip('All', 'all', financialYearListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Year', 'year', financialYearListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Added By', 'add_by', financialYearListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Creation Date', 'created_on', financialYearListController),
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

  Widget _buildSortChip(
    String label, 
    String value, 
    FinancialYearListController controller
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