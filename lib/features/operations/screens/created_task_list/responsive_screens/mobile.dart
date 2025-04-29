import 'package:doc_sync/features/operations/controllers/created_task_list_controller.dart';
import 'package:doc_sync/features/operations/models/task_model.dart';
import 'package:doc_sync/features/operations/screens/created_task_list/widgets/task_card.dart';
import 'package:doc_sync/features/operations/screens/new_task/widgets/route_header.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:intl/intl.dart';

class TaskListMobileScreen extends StatelessWidget {
  const TaskListMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskListController = Get.find<TaskListController>();
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Text controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: taskListController.searchQuery.value,
    );

    return SafeArea(
      child: LiquidPullToRefresh(
        key: taskListController.refreshIndicatorKey,
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => taskListController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: RouteHeader(
                  title: 'Created Tasks List',
                  subtitle: 'Home / Created Tasks List / Data',
                ),
              ),
              // Date indicator and refresh section
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.white),
                  ),
                  child: InkWell(
                    onTap: () => _selectDate(Get.context!, taskListController),
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
                                        taskListController
                                                .allotedDateStr
                                                .value
                                                .isEmpty
                                            ? "No date selected"
                                            : DateFormat("dd MMM, yyyy").format(
                                              DateTime.parse(
                                                taskListController
                                                    .allotedDateStr
                                                    .value,
                                              ),
                                            ),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              taskListController
                                                      .allotedDateStr
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
                            _buildRefreshButton(taskListController),
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
                              taskListController.searchQuery.value) {
                            searchController.text =
                                taskListController.searchQuery.value;
                            searchController
                                .selection = TextSelection.fromPosition(
                              TextPosition(
                                offset: searchController.text.length,
                              ),
                            );
                          }

                          return TextField(
                            controller: searchController,
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              hintText: 'Search tasks, clients, file no...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon:
                                  taskListController
                                          .searchQuery
                                          .value
                                          .isNotEmpty
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
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildSortChip(
                                'Date',
                                'date',
                                taskListController,
                              ),
                              const SizedBox(width: 8),
                              _buildSortChip(
                                'Task Name',
                                'name',
                                taskListController,
                              ),
                              const SizedBox(width: 8),
                              _buildSortChip(
                                'Client',
                                'client',
                                taskListController,
                              ),
                              const SizedBox(width: 8),
                              _buildSortChip(
                                'Priority',
                                'priority',
                                taskListController,
                              ),
                              const SizedBox(width: 8),
                              _buildSortChip(
                                'Status',
                                'status',
                                taskListController,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Task list
              GetX<TaskListController>(
                builder: (controller) {
                  if (controller.isLoading.value) {
                    return _buildLoadingShimmer();
                  }

                  if (controller.filteredTasks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return Column(
                    children: [
                      _buildTaskList(
                        context: context,
                        taskListController: controller,
                        cardBackgroundColor: cardBackgroundColor,
                        textColor: textColor,
                        subtleTextColor: subtleTextColor,
                      ),

                      // Pagination controls
                      _buildPaginationControls(
                        controller,
                        cardBackgroundColor,
                        textColor,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(TaskListController controller) {
    return OutlinedButton.icon(
      onPressed: () async {
        final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
            controller.refreshIndicatorKey;

        await controller.clearDate();

        if (refreshIndicatorKey.currentState != null) {
          await refreshIndicatorKey.currentState!.show();
        }
      },
      icon: const Icon(Icons.list_alt, size: 16),
      label: const Text('Show All'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: AppShimmerEffect(width: double.infinity, height: 80),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              'No tasks found with current filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter settings',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList({
    required BuildContext context,
    required TaskListController taskListController,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: taskListController.paginatedTasks.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final task = taskListController.paginatedTasks[index];
        return _buildTaskCard(
          context: context,
          task: task,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        );
      },
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required Task task,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return TaskExpansionCard(
      task: task,
      cardBackgroundColor: cardBackgroundColor,
      textColor: textColor,
      subtleTextColor: subtleTextColor,
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

  Widget _buildPaginationControls(
    TaskListController controller,
    Color cardBackgroundColor,
    Color textColor,
  ) {
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
                  child: Obx(
                    () => DropdownButton<int>(
                      value: controller.itemsPerPage.value,
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
                          controller.itemsPerPage.value = value;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('entries', style: TextStyle(color: textColor)),
              ],
            ),
            const SizedBox(height: 16),
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(
                  () => IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        controller.currentPage.value > 0
                            ? controller.previousPage
                            : null,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          controller.currentPage.value > 0
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade200,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => Text(
                    'Page ${controller.currentPage.value + 1} of ${controller.totalPages}',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Obx(
                  () => IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed:
                        controller.currentPage.value < controller.totalPages - 1
                            ? controller.nextPage
                            : null,
                    style: IconButton.styleFrom(
                      backgroundColor:
                          controller.currentPage.value <
                                  controller.totalPages - 1
                              ? AppColors.primary.withOpacity(0.1)
                              : Colors.grey.shade200,
                    ),
                  ),
                ),
              ],
            ),
            // Page info
            Obx(() {
              final start =
                  controller.currentPage.value * controller.itemsPerPage.value +
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

  Future<void> _selectDate(
    BuildContext context,
    TaskListController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(
        (controller.allotedDateStr.value.isNotEmpty)
            ? controller.allotedDateStr.value
            : DateTime.now().toString(),
      ),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
              surface: AppColors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Update the date first
      await controller.setAllotedDate(picked);

      // Then fetch tasks with refresh animation
      final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey =
          controller.refreshIndicatorKey;

      if (refreshIndicatorKey.currentState != null) {
        await refreshIndicatorKey.currentState!.show();
      }
    }
  }
}
