import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:doc_sync/features/operations/models/admin_verification_task_model.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/widgets/task_card.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:intl/intl.dart';

class AdminVerificationMobileScreen extends StatelessWidget {
  const AdminVerificationMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVerificationController = Get.find<AdminVerificationController>();
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: adminVerificationController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: adminVerificationController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => adminVerificationController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Admin Verification',
                  subtitle: 'Home / Admin Verification / Data',
                ),
              ),
              // Date indicator and refresh section
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white),
                  ),
                  child: InkWell(
                    onTap:
                        () => _selectDate(
                          Get.context!,
                          adminVerificationController,
                        ),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Date',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(
                                      () => Text(
                                        adminVerificationController
                                                .filterTaskDateStr
                                                .value
                                                .isEmpty
                                            ? "No date selected"
                                            : DateFormat("dd MMM, yyyy").format(
                                              DateTime.parse(
                                                adminVerificationController
                                                    .filterTaskDateStr
                                                    .value,
                                              ),
                                            ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              adminVerificationController
                                                      .filterTaskDateStr
                                                      .value
                                                      .isEmpty
                                                  ? AppColors.textSecondary
                                                  : textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            _buildRefreshButton(adminVerificationController),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Search and filter section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
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
                            searchController.text =
                                adminVerificationController.searchQuery.value;
                            searchController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: searchController.text.length,
                              ),
                            );
                          }

                          return TextField(
                            controller: searchController,
                            onTapOutside:
                                (event) =>
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus(),
                            decoration: InputDecoration(
                              hintText: 'Search tasks, clients, file no...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon:
                                  adminVerificationController
                                          .searchQuery
                                          .value
                                          .isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          searchController.clear();
                                          adminVerificationController
                                              .updateSearch('');
                                        },
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                                adminVerificationController,
                                Icons.list_alt,
                                adminVerificationController.totalTasksCount,
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

                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: _buildStatusFilterCard(
                                  'Awaiting',
                                  'awaiting',
                                  adminVerificationController,
                                  Icons.hourglass_empty,
                                  adminVerificationController.totalAwaiting,
                                  Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildStatusFilterCard(
                                  'Reallotted',
                                  'reallotted',
                                  adminVerificationController,
                                  Icons.replay,
                                  adminVerificationController.totalReallotted,
                                  Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Priority filters
                        Text(
                          'Priority:',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
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
                                  adminVerificationController
                                      .highPriorityCount
                                      .value,
                                  Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPriorityFilterCard(
                                  'Medium',
                                  'medium',
                                  adminVerificationController,
                                  adminVerificationController
                                      .mediumPriorityCount
                                      .value,
                                  Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildPriorityFilterCard(
                                  'Low',
                                  'low',
                                  adminVerificationController,
                                  adminVerificationController
                                      .lowPriorityCount
                                      .value,
                                  Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Task list
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(
                  () =>
                      adminVerificationController.isLoading.value
                          ? const AppShimmerEffect(
                            width: double.infinity,
                            height: 80,
                          )
                          : adminVerificationController.filteredTasks.isEmpty
                          ? const Center(child: Text('No tasks found'))
                          : _buildTaskList(
                            context: context,
                            adminVerificationController:
                                adminVerificationController,
                            cardBackgroundColor: cardBackgroundColor,
                            textColor: textColor,
                            subtleTextColor: subtleTextColor,
                          ),
                ),
              ),

              // Pagination
              Obx(
                () =>
                    adminVerificationController.isLoading.value
                        ? const SizedBox()
                        : _buildPaginationControls(
                          adminVerificationController,
                          cardBackgroundColor,
                          textColor,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(AdminVerificationController controller) {
    return IconButton(
      onPressed: controller.fetchTasks,
      icon: const Icon(Icons.refresh),
    );
  }

  void _selectDate(
    BuildContext context,
    AdminVerificationController controller,
  ) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        controller.setAllotedDate(date);
      }
    });
  }

  Widget _buildFilterChip(
    String label,
    String value,
    AdminVerificationController controller,
    IconData icon,
    int count,
    Color color,
  ) {
    final isSelected = controller.activeFilters.contains(value);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            '$label ($count)',
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => controller.updateFilter(value),
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
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
      final isSelected =
          value == 'all'
              ? controller.activeFilters.isEmpty
              : controller.activeFilters.contains(value);

      return Card(
        elevation: isSelected ? 2 : 0,
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => controller.updateFilter(value),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: isSelected ? color : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPriorityFilterCard(
    String label,
    String value,
    AdminVerificationController controller,
    int count,
    Color color,
  ) {
    final isSelected = controller.activeFilters.contains(value);
    return Card(
      elevation: 0,
      color: isSelected ? color.withOpacity(0.1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? color : Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => controller.updateFilter(value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList({
    required BuildContext context,
    required AdminVerificationController adminVerificationController,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: adminVerificationController.paginatedTasks.length,
      itemBuilder: (context, index) {
        final task = adminVerificationController.paginatedTasks[index];
        return TaskExpansionCard(
          task: task,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        );
      },
    );
  }

  Widget _buildPaginationControls(
    AdminVerificationController controller,
    Color cardBackgroundColor,
    Color textColor,
  ) {
    return Card(
      elevation: 0,
      color: cardBackgroundColor,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous page button
                OutlinedButton.icon(
                  onPressed: controller.previousPage,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Page info
                Obx(() {
                  final start =
                      (controller.currentPage.value - 1) *
                          controller.itemsPerPage +
                      1;
                  final end = start + controller.paginatedTasks.length - 1;
                  final total = controller.filteredTasks.length;

                  return Text(
                    'Showing $start to $end of $total entries',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withOpacity(0.7),
                    ),
                  );
                }),

                // Next page button
                OutlinedButton.icon(
                  onPressed: controller.nextPage,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Next'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
