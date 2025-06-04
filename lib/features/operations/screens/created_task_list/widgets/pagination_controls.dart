import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginationControls extends StatelessWidget {
  final TaskListController controller;
  final Color cardBackgroundColor;
  final Color textColor;

  const PaginationControls({
    super.key,
    required this.controller,
    required this.cardBackgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: cardBackgroundColor,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Items per page selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show', style: TextStyle(color: textColor)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                      value: controller.itemsPerPage,
                      underline: const SizedBox(),
                      items:
                          [5, 10, 15, 20].map((value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.itemsPerPage = value;
                        }
                      },
                    ),
                ),
                const SizedBox(width: 8),
                Text('entries', style: TextStyle(color: textColor)),
              ],
            ),
            const SizedBox(height: 16),
            // Enhanced page navigation
            Obx(() => _buildPageNavigator()),
            // Page info
            Obx(() {
              final start =
                  controller.currentPage.value * controller.itemsPerPage +
                  1;
              final end = start + controller.paginatedTasks.length - 1;
              final total = controller.filteredTasks.length;

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Showing $start to $end of $total entries',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPageNavigator() {
    final int totalPages = controller.totalPages;
    final int currentPage = controller.currentPage.value;
    
    // Calculate skip size for information display
    int skipSize = 5;
    if (totalPages > 300) {
      skipSize = 100;
    } else if (totalPages > 100) {
      skipSize = 50;
    } else if (totalPages > 50) {
      skipSize = 10;
    }
    
    // Determine which 3 page numbers to show
    int midPage = currentPage;
    int leftPage = midPage - 1;
    int rightPage = midPage + 1;
    
    // Adjust if we're at the edges
    if (leftPage < 0) {
      leftPage = 0;
      midPage = 1;
      rightPage = 2;
    } else if (rightPage >= totalPages) {
      if (totalPages >= 3) {
        rightPage = totalPages - 1;
        midPage = rightPage - 1;
        leftPage = midPage - 1;
      } else {
        // Handle case with fewer than 3 pages
        leftPage = 0;
        midPage = totalPages > 1 ? 1 : 0;
        rightPage = totalPages > 2 ? 2 : midPage;
      }
    }
    
    // Build the navigation controls
    return Container(
      height: 48,
      width: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Skip multiple pages backward button
              _buildDoubleArrowButton(
                icon: Icons.keyboard_double_arrow_left,
                onTap: totalPages > 10 ? controller.skipPagesBackward : null,
                isEnabled: currentPage > 0,
                tooltip: "Skip $skipSize pages back",
              ),
              const SizedBox(width: 2),
              
              // Previous page button
              _buildSingleArrowButton(
                icon: Icons.chevron_left,
                onTap: controller.previousPage,
                isEnabled: currentPage > 0,
                tooltip: "Previous page",
              ),
              const SizedBox(width: 4),
              
              // The 3 main page numbers
              if (totalPages > 0 && leftPage >= 0)
                _buildPageButton(leftPage, currentPage),
              if (totalPages > 1 && midPage < totalPages && midPage >= 0)
                _buildPageButton(midPage, currentPage),
              if (totalPages > 2 && rightPage < totalPages && rightPage >= 0)
                _buildPageButton(rightPage, currentPage),
              
              const SizedBox(width: 4),
              // Next page button
              _buildSingleArrowButton(
                icon: Icons.chevron_right,
                onTap: controller.nextPage,
                isEnabled: currentPage < totalPages - 1,
                tooltip: "Next page",
              ),
              const SizedBox(width: 2),
              
              // Skip multiple pages forward button
              _buildDoubleArrowButton(
                icon: Icons.keyboard_double_arrow_right,
                onTap: totalPages > 10 ? controller.skipPagesForward : null,
                isEnabled: currentPage < totalPages - 1,
                tooltip: "Skip $skipSize pages forward",
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSingleArrowButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Material(
          color: isEnabled ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isEnabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(
                icon,
                size: 20,
                color: isEnabled ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDoubleArrowButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isEnabled,
    required String tooltip,
  }) {
    final bool isActive = isEnabled && onTap != null;
    
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        child: Material(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: isActive ? onTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.primary : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPageButton(int pageIndex, int currentPage) {
    final bool isSelected = pageIndex == currentPage;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? AppColors.primary : cardBackgroundColor,
        elevation: isSelected ? 2 : 0,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isSelected ? null : () => controller.goToPage(pageIndex),
          child: Container(
            width: 32,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${pageIndex + 1}',
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
