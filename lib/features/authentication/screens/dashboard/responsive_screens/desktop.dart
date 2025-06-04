import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/widgets/greeting_with_route.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/widgets/summary_cards.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:iconsax/iconsax.dart';

class DashboardDesktopScreen extends StatefulWidget {
  const DashboardDesktopScreen({super.key});

  @override
  State<DashboardDesktopScreen> createState() => _DashboardDesktopScreenState();
}

class _DashboardDesktopScreenState extends State<DashboardDesktopScreen> {
  late DashboardController dashboardController;
  
  @override
  void initState() {
    super.initState();
    // Get or create the dashboard controller
    if (!Get.isRegistered<DashboardController>()) {
      dashboardController = Get.put(DashboardController());
    } else {
      dashboardController = Get.find<DashboardController>();
    }
    
    // Fetch dashboard data when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will only fetch if dataAlreadyFetched is false
      dashboardController.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using a primary color similar to the image, adjust as needed
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    return Expanded(
      child: LiquidPullToRefresh(
        animSpeedFactor: 2.3,
        color: AppColors.primary,
        backgroundColor: AppColors.light,
        showChildOpacityTransition: false,
        onRefresh: () => dashboardController.refreshDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section (removed the search bar)
              Obx(
                () => GreetingWithRoute(
                  userName: dashboardController.userController.user.value.name,
                  subtleTextColor: subtleTextColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Dashboard Overview Heading
              Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Summary Cards Grid - fixed 3 cards per row for desktop
              Obx(
                () {
                  final List<Map<String, dynamic>> summaryCardsData = [
                    {
                      'title': 'Tasks Created',
                      'value': dashboardController.todayCreated.value.toString(),
                      'icon': Icons.list_alt_outlined,
                      'iconColor': Colors.blue,
                      'subtitle': 'Today',
                    },
                    {
                      'title': 'Tasks Completed',
                      'value': dashboardController.todayCompleted.value.toString(),
                      'icon': Icons.check_circle_outline,
                      'iconColor': Colors.green,
                      'subtitle': 'Today',
                    },
                    {
                      'title': 'Pending (Today)',
                      'value': dashboardController.todayPending.value.toString(),
                      'icon': Icons.pending_actions_outlined,
                      'iconColor': Colors.orange,
                      'subtitle': 'Today (Pending + Allotted + Re-Allotted)',
                    },
                    {
                      'title': 'Pending (Total)',
                      'value': dashboardController.totalPending.value.toString(),
                      'icon': Icons.hourglass_top_outlined,
                      'iconColor': Colors.redAccent,
                      'subtitle': '(Total Pending + Allotted + Re-Allotted)',
                    },
                    {
                      'title': 'High Priority',
                      'value': dashboardController.totalTasks.value.toString(),
                      'icon': Icons.priority_high_rounded,
                      'iconColor': Colors.red,
                      'subtitle': '(Total Pending + Allotted + Re-Allotted)',
                    },
                    {
                      'title': 'Running Late',
                      'value': dashboardController.runningLate.value.toString(),
                      'icon': Icons.running_with_errors_outlined,
                      'iconColor': Colors.deepOrange,
                      'subtitle': '(Total Pending + Allotted + Re-Allotted)',
                    },
                  ];
                  
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 3 cards per row for desktop
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.6, // Wider cards for desktop
                    ),
                    itemCount: summaryCardsData.length,
                    itemBuilder: (context, index) {
                      final cardData = summaryCardsData[index];
                      
                      // Create the value widget based on loading state
                      Widget valueDisplay;
                      if (dashboardController.isLoading.value) {
                        valueDisplay = AppShimmerEffect(width: 100, height: 40);
                      } else {
                        valueDisplay = Text(
                          cardData['value'],
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cardData['iconColor'],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                      
                      return buildSummaryCard(
                  context: context,
                        title: cardData['title'],
                        valueWidget: valueDisplay,
                        icon: cardData['icon'],
                        iconColor: cardData['iconColor'],
                        subtitle: cardData['subtitle'],
                  cardBackgroundColor: cardBackgroundColor,
                  textColor: textColor,
                  subtleTextColor: subtleTextColor,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),
              
              // Work Flow Section Title
              Text(
                'Work Flow | Over-all',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Employee performance cards (replacing DataTable)
              _buildEmployeePerformanceList(
                context: context,
                dashboardController: dashboardController,
                cardBackgroundColor: cardBackgroundColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Employee performance list (replacement for DataTable)
  Widget _buildEmployeePerformanceList({
    required BuildContext context,
    required DashboardController dashboardController,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    // Controller for the search field
    final TextEditingController searchController = TextEditingController(
      text: dashboardController.searchQuery.value,
    );

    return Obx(() {
      // Keep the controller in sync with the observable
      if (searchController.text != dashboardController.searchQuery.value) {
        searchController.text = dashboardController.searchQuery.value;
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
      }

      if (dashboardController.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: AppShimmerEffect(width: double.infinity, height: 400),
          ),
        );
      }

      if (dashboardController.tableItems.isEmpty) {
        return Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      }

      return Column(
        children: [
          // Search and Filter Card
              Card(
            elevation: 0,
            color: cardBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field - full width
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: dashboardController.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                searchController.clear();
                                dashboardController.updateSearch('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onChanged: dashboardController.updateSearch,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Row with sort options and items per page
                  Row(
                    children: [
                      // Sort label
                      Text(
                        'Sort by:',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Sort chips in a row
                      _buildSortChip(
                        'Name',
                        'name',
                        dashboardController,
                        textColor,
                      ),
                      const SizedBox(width: 8),
                      _buildSortChip(
                        'Pending',
                        'pending',
                        dashboardController,
                        textColor,
                      ),
                      const SizedBox(width: 8),
                      _buildSortChip(
                        'Completed',
                        'completed',
                        dashboardController,
                        textColor,
                      ),
                      
                      const Spacer(),
                      
                      // Items per page selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text('Show:', style: TextStyle(color: textColor)),
                            const SizedBox(width: 8),
                            DropdownButton<int>(
                              value: dashboardController.itemsPerPage.value,
                              underline: const SizedBox(),
                              items: [5, 10, 15, 20, 25].map((value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  dashboardController.itemsPerPage.value = value;
                                  dashboardController.currentPage.value = 0;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Employee List View (similar to tablet implementation)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboardController.paginatedItems.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final item = dashboardController.paginatedItems[index];
              final absoluteIndex = index +
                  (dashboardController.currentPage.value *
                      dashboardController.itemsPerPage.value);

              // Calculate totals
              final int totalRemaining = (item.pending ?? 0) +
                  (item.alloted ?? 0) +
                  (item.reAlloted ?? 0) +
                  (item.awaitingClient ?? 0);

              final int totalTasks = totalRemaining + (item.completed ?? 0);
              final completionPercentage = totalTasks > 0
                  ? ((item.completed ?? 0) / totalTasks * 100).toInt()
                  : 0;

              Color statusColor = Colors.green;
              if ((item.pending ?? 0) > 0) statusColor = Colors.orange;
              if (totalRemaining > 5) statusColor = Colors.red;

              return Card(
                elevation: 2,
                color: cardBackgroundColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    scaffoldBackgroundColor: AppColors.light,
                  ),
                  child: Obx(() {
                    final isExpanded =
                        dashboardController.expansionStates[absoluteIndex] ?? false;
                    return ExpansionTile(
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        dashboardController.expansionStates[absoluteIndex] = expanded;
                      },
                      title: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${absoluteIndex + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                Text(
                                  item.name ?? 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.completed ?? 0}/$totalTasks tasks completed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subtleTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Completion percentage
                          Text(
                            '$completionPercentage%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Animated rotation of arrow
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 200),
                            tween: Tween<double>(
                              begin: 0,
                              end: isExpanded ? 1 : 0,
                            ),
                            builder: (_, value, __) {
                              return Transform.rotate(
                                angle: value * 3.14159,
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: subtleTextColor,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8.0,
                          ),
                          child: Column(
                            children: [
                              // Progress bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: completionPercentage / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  color: statusColor,
                                  minHeight: 6,
                                ),
                      ),
                      const SizedBox(height: 16),
                              
                              // Task statistics - horizontal layout for desktop
                              Wrap(
                                spacing: 16,
                                runSpacing: 8,
                                children: [
                                  _buildStatRow(
                                    context,
                                    'Pending Tasks',
                                    '${item.pending ?? 0}',
                                    Icons.hourglass_empty,
                                    Colors.orange,
                                    textColor,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Completed Tasks',
                                    '${item.completed ?? 0}',
                                    Icons.check_circle_outline,
                                    Colors.green,
                                    textColor,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Allotted Tasks',
                                    '${item.alloted ?? 0}',
                                    Icons.assignment_outlined,
                                    Colors.blue,
                                    textColor,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Re-Allotted Tasks',
                                    '${item.reAlloted ?? 0}',
                                    Icons.replay_outlined,
                                    Colors.purple,
                                    textColor,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Awaiting Client',
                                    '${item.awaitingClient ?? 0}',
                                    Icons.person_outline,
                                    Colors.teal,
                                    textColor,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Total Remaining',
                                    '$totalRemaining',
                                    Icons.pending_actions,
                                    Colors.red,
                                    textColor,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Total Tasks',
                                    '$totalTasks',
                                    Icons.assignment,
                                    Colors.indigo,
                                    textColor,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            },
          ),
          
          // Pagination Controls
          Card(
            elevation: 0,
            color: cardBackgroundColor,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Items per page info
                  Text(
                    'Showing ${dashboardController.paginatedItems.length} of ${dashboardController.filteredItems.length} entries',
                    style: TextStyle(color: textColor),
                  ),
                  
                  const Spacer(),
                  
                  // Navigation buttons
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: dashboardController.currentPage.value > 0
                        ? () => dashboardController.currentPage.value = 0
                        : null,
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      backgroundColor: dashboardController.currentPage.value > 0
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: dashboardController.currentPage.value > 0
                        ? dashboardController.previousPage
                        : null,
                    style: IconButton.styleFrom(
                      backgroundColor: dashboardController.currentPage.value > 0
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Page ${dashboardController.currentPage.value + 1} of ${dashboardController.totalPages}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: dashboardController.currentPage.value <
                            dashboardController.totalPages - 1
                        ? dashboardController.nextPage
                        : null,
                    style: IconButton.styleFrom(
                      backgroundColor: dashboardController.currentPage.value <
                              dashboardController.totalPages - 1
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: dashboardController.currentPage.value <
                            dashboardController.totalPages - 1
                        ? () => dashboardController.currentPage.value =
                            dashboardController.totalPages - 1
                        : null,
                    style: IconButton.styleFrom(
                      backgroundColor: dashboardController.currentPage.value <
                              dashboardController.totalPages - 1
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
          ),
        ],
      );
    });
  }

  // Helper method for sort chips
  Widget _buildSortChip(
    String label,
    String field,
    DashboardController controller,
    Color textColor,
  ) {
    return Obx(() {
      final isSelected = controller.sortBy.value == field;
      return FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                controller.sortAscending.value
                    ? Iconsax.arrow_up_3
                    : Iconsax.arrow_down,
                size: 16,
              ),
            ],
          ],
        ),
        selected: isSelected,
        onSelected: (_) => controller.updateSort(field),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    });
  }

  // Helper to build stat row with more compact layout for desktop
  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor, {
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}