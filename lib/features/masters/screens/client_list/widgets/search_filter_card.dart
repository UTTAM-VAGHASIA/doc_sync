import 'package:doc_sync/features/masters/controllers/client_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterCard extends StatelessWidget {
  final ClientListController clientListController;
  final TextEditingController searchController;

  const SearchFilterCard({
    Key? key,
    required this.clientListController,
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
                  clientListController.searchQuery.value) {
                searchController.text = clientListController.searchQuery.value;
                searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: searchController.text.length),
                );
              }

              return TextField(
                controller: searchController,
                onTapOutside:
                    (event) => FocusManager.instance.primaryFocus?.unfocus(),
                decoration: InputDecoration(
                  hintText: 'Search clients, file no, contacts...',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  suffixIcon:
                      clientListController.searchQuery.value.isNotEmpty
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
                'All Clients',
                'all',
                clientListController,
                Iconsax.profile_2user,
                clientListController.totalClientsCount,
                AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 8),

            // Status filter chips row
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Active',
                      'active',
                      clientListController,
                      Iconsax.tick_circle,
                      clientListController.totalActiveClients.value,
                      Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusFilterCard(
                      'Inactive',
                      'inactive',
                      clientListController,
                      Iconsax.close_circle,
                      clientListController.totalInactiveClients.value,
                      Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sort options
            Text(
              'Sort By:',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Sort dropdown and direction toggle
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      value: clientListController.sortBy.value,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'firm_name',
                          child: Text('Firm Name'),
                        ),
                        DropdownMenuItem(
                          value: 'file_no',
                          child: Text('File Number'),
                        ),
                        DropdownMenuItem(
                          value: 'contact_person',
                          child: Text('Contact Person'),
                        ),
                        DropdownMenuItem(
                          value: 'email',
                          child: Text('Email'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          clientListController.updateSort(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => IconButton(
                    onPressed: () => clientListController.sortAscending.toggle(),
                    icon: Icon(
                      clientListController.sortAscending.value
                          ? Iconsax.sort
                          : Iconsax.arrow_down,
                      size: 24,
                    ),
                    tooltip: clientListController.sortAscending.value
                        ? 'Ascending'
                        : 'Descending',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Full width filter card
  Widget _buildFullWidthFilterCard(
    String label,
    String value,
    ClientListController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    return Material(
      color: controller.activeFilters.contains(value) ||
              (value == 'all' && controller.activeFilters.isEmpty)
          ? color.withOpacity(0.1)
          : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: controller.activeFilters.contains(value) ||
                  (value == 'all' && controller.activeFilters.isEmpty)
              ? color
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.updateFilter(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: controller.activeFilters.contains(value) ||
                        (value == 'all' && controller.activeFilters.isEmpty)
                    ? color
                    : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: controller.activeFilters.contains(value) ||
                            (value == 'all' && controller.activeFilters.isEmpty)
                        ? color
                        : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: controller.activeFilters.contains(value) ||
                          (value == 'all' && controller.activeFilters.isEmpty)
                      ? color.withOpacity(0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: controller.activeFilters.contains(value) ||
                            (value == 'all' && controller.activeFilters.isEmpty)
                        ? color
                        : Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Half width status filter card
  Widget _buildStatusFilterCard(
    String label,
    String value,
    ClientListController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    return Material(
      color: controller.activeFilters.contains(value)
          ? color.withOpacity(0.1)
          : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: controller.activeFilters.contains(value)
              ? color
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.updateFilter(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: controller.activeFilters.contains(value)
                    ? color
                    : Colors.grey.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: controller.activeFilters.contains(value)
                        ? color
                        : Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: controller.activeFilters.contains(value)
                      ? color.withOpacity(0.2)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: controller.activeFilters.contains(value)
                        ? color
                        : Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 