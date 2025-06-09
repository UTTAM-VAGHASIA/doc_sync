import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterCard extends StatelessWidget {
  final ClientListController clientListController;
  final TextEditingController searchController;

  const SearchFilterCard({
    super.key,
    required this.clientListController,
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
                if (searchController.text != clientListController.searchQuery.value) {
                  searchController.text = clientListController.searchQuery.value;
                  searchController.selection = TextSelection.fromPosition(
                    TextPosition(offset: searchController.text.length),
                  );
                }

                return TextField(
                  controller: searchController,
                  onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    hintText: 'Search clients, file no, contacts...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: clientListController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              searchController.clear();
                              clientListController.updateSearch('');
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
                  onChanged: clientListController.updateSearch,
                );
              }),
            ),
            
            const SizedBox(width: 12),
            
            // Filter Button
            Obx(() => Badge(
              isLabelVisible: clientListController.activeFilters.isNotEmpty,
              label: Text(clientListController.activeFilters.length.toString()),
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
        child: _FilterBottomSheet(clientListController: clientListController),
      ),
    );
  }
}

class _FilterBottomSheet extends StatelessWidget {
  final ClientListController clientListController;

  const _FilterBottomSheet({required this.clientListController});

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
                      if (clientListController.activeFilters.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            clientListController.activeFilters.clear();
                            clientListController.updateFilter('all');
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reset'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                        ),
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
                      'All Clients',
                      'all',
                      clientListController,
                      Iconsax.profile_2user,
                      clientListController.totalClientsCount,
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
                            clientListController,
                            Iconsax.tick_circle,
                            clientListController.totalEnableClients.value,
                            Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatusFilterCard(
                            'Disabled',
                            'disable',
                            clientListController,
                            Iconsax.close_circle,
                            clientListController.totalDisableClients.value,
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
                        _buildSortChip('All', 'all', clientListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Firm Name', 'firm_name', clientListController),
                        const SizedBox(width: 8),
                        _buildSortChip('File Number', 'file_no', clientListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Contact Person', 'contact_person', clientListController),
                        const SizedBox(width: 8),
                        _buildSortChip('Email', 'email', clientListController),
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
    ClientListController controller,
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
    ClientListController controller,
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
    ClientListController controller
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