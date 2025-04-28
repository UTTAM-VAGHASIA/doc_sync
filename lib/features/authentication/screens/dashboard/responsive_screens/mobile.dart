import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/widgets/summary_cards.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class DashboardMobileScreen extends StatelessWidget {
  const DashboardMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Fetch data if needed
    if (!dashboardController.dataAlreadyFetched.value) {
      dashboardController.fetchDashboardData();
    }

    return LiquidPullToRefresh(
      animSpeedFactor: 2.3,
      color: AppColors.primary,
      backgroundColor: AppColors.light,
      showChildOpacityTransition: false,
      onRefresh: () => dashboardController.refreshDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        hitTestBehavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Greeting and route info ---
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                right: 16.0,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            'Welcome, ${dashboardController.userController.user.value.name ?? 'User'}!',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'home / dashboard',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: subtleTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Summary Cards Carousel ---
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Dashboard Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Summary Cards as Carousel
             _buildSummaryCards(
                context: context,
                dashboardController: dashboardController,
                cardBackgroundColor: cardBackgroundColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),

            const SizedBox(height: 24),

            // --- Work Flow Section (Employee Performance) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Work Flow | Over-all',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Employee performance cards (replacing DataTable)
            _buildEmployeePerformanceList(
              context: context,
              dashboardController: dashboardController,
              cardBackgroundColor: cardBackgroundColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Build carousel for summary cards
  Widget _buildSummaryCards({
    required BuildContext context,
    required DashboardController dashboardController,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    // Calculate the width of each card based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns for wider screens, 2 for narrow
    final cardWidth = (screenWidth - (32 + (crossAxisCount - 1) * 8)) / crossAxisCount;
    final cardHeight = cardWidth * 0.8; // Maintain aspect ratio

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: cardWidth / cardHeight,
        ),
        itemCount: 6, // Fixed number of summary cards
        itemBuilder: (context, index) {
          // Handle each card index individually to avoid reactive issues
          String title;
          IconData icon;
          Color iconColor;
          String subtitle;

          switch (index) {
            case 0:
              title = 'Tasks Created';
              icon = Icons.list_alt_outlined;
              iconColor = Colors.blue;
              subtitle = 'Today';
              break;
            case 1:
              title = 'Tasks Completed';
              icon = Icons.check_circle_outline;
              iconColor = Colors.green;
              subtitle = 'Today';
              break;
            case 2:
              title = 'Pending (Today)';
              icon = Icons.pending_actions_outlined;
              iconColor = Colors.orange;
              subtitle = 'Today (Pending + Allotted + Re-Allotted)';
              break;
            case 3:
              title = 'Pending (Total)';
              icon = Icons.hourglass_top_outlined;
              iconColor = Colors.redAccent;
              subtitle = '(Total Pending + Allotted + Re-Allotted)';
              break;
            case 4:
              title = 'High Priority';
              icon = Icons.priority_high_rounded;
              iconColor = Colors.red;
              subtitle = '(Total Pending + Allotted + Re-Allotted)';
              break;
            default: // 5
              title = 'Running Late';
              icon = Icons.running_with_errors_outlined;
              iconColor = Colors.deepOrange;
              subtitle = '(Total Pending + Allotted + Re-Allotted)';
              break;
          }

          return Obx(() {
            // Create individual reactive widget for each card
            Widget valueDisplay;
            String valueText;

            // Get the appropriate value based on index
            switch (index) {
              case 0:
                valueText = dashboardController.todayCreated.value.toString();
                break;
              case 1:
                valueText = dashboardController.todayCompleted.value.toString();
                break;
              case 2:
                valueText = dashboardController.todayPending.value.toString();
                break;
              case 3:
                valueText = dashboardController.totalPending.value.toString();
                break;
              case 4:
                valueText = dashboardController.totalTasks.value.toString();
                break;
              default: // 5
                valueText = dashboardController.runningLate.value.toString();
                break;
            }

            if (dashboardController.isLoading.value) {
              valueDisplay = AppShimmerEffect(width: 64, height: 32);
            } else {
              valueDisplay = Text(
                valueText,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            }
            
            return buildSummaryCard(
              context: context,
              title: title,
              valueWidget: valueDisplay,
              icon: icon,
              iconColor: iconColor,
              subtitle: subtitle,
              cardBackgroundColor: cardBackgroundColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
              heroTag: index,
              onTap: () => _openExpandedCard(
                context,
                index,
                title,
                valueDisplay,
                icon,
                iconColor,
                subtitle,
                cardBackgroundColor,
                textColor,
                subtleTextColor,
              ),
            );
          });
        },
      ),
    );
  }

  // Open expanded card
  void _openExpandedCard(
    BuildContext context,
    int heroTag,
    String title,
    Widget valueWidget,
    IconData icon,
    Color iconColor,
    String subtitle,
    Color cardBackgroundColor,
    Color textColor,
    Color subtleTextColor,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => ExpandedSummaryCard(
          heroTag: heroTag,
          title: title,
          valueWidget: valueWidget,
          icon: icon,
          iconColor: iconColor,
          subtitle: subtitle,
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        ),
        transitionDuration: const Duration(milliseconds: 350),
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
        return const 
        Padding(padding: EdgeInsets.all(16.0),child: Center(
          child: AppShimmerEffect(width: double.infinity, height: 400
        ),),);
      }

      if (dashboardController.tableItems.isEmpty) {
        return const Center(child: Text('No data available'));
      }

      return Column(
        children: [
          // Search and Filter Section
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
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search employees...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            dashboardController.searchQuery.value.isNotEmpty
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
                          vertical: 12,
                        ),
                      ),
                      onChanged: dashboardController.updateSearch,
                    ),
                    const SizedBox(height: 16),

                    // Sort Options
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
                          Obx(() => FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Name'),
                                if (dashboardController.sortBy.value == 'name') ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    dashboardController.sortAscending.value
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            selected: dashboardController.sortBy.value == 'name',
                            onSelected: (_) => dashboardController.updateSort('name'),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: dashboardController.sortBy.value == 'name' 
                                  ? AppColors.primary 
                                  : textColor,
                              fontWeight: dashboardController.sortBy.value == 'name' 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          )),
                          const SizedBox(width: 8),
                          Obx(() => FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Pending'),
                                if (dashboardController.sortBy.value == 'pending') ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    dashboardController.sortAscending.value
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            selected: dashboardController.sortBy.value == 'pending',
                            onSelected: (_) => dashboardController.updateSort('pending'),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: dashboardController.sortBy.value == 'pending' 
                                  ? AppColors.primary 
                                  : textColor,
                              fontWeight: dashboardController.sortBy.value == 'pending' 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          )),
                          const SizedBox(width: 8),
                          Obx(() => FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Completed'),
                                if (dashboardController.sortBy.value == 'completed') ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    dashboardController.sortAscending.value
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            selected: dashboardController.sortBy.value == 'completed',
                            onSelected: (_) => dashboardController.updateSort('completed'),
                            backgroundColor: Colors.grey.shade200,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: dashboardController.sortBy.value == 'completed' 
                                  ? AppColors.primary 
                                  : textColor,
                              fontWeight: dashboardController.sortBy.value == 'completed' 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // List Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboardController.paginatedItems.length,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemBuilder: (context, index) {
              final item = dashboardController.paginatedItems[index];
              final absoluteIndex =
                  index +
                  (dashboardController.currentPage.value *
                      dashboardController.itemsPerPage.value);

              // Calculate totals
              final int totalRemaining =
                  (item.pending ?? 0) +
                  (item.alloted ?? 0) +
                  (item.reAlloted ?? 0) +
                  (item.awaitingClient ?? 0);

              final int totalTasks = totalRemaining + (item.completed ?? 0);
              final completionPercentage =
                  totalTasks > 0
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
                  child: ExpansionTile(
                    key: ValueKey("expansion-tile-$absoluteIndex"),
                    initiallyExpanded: dashboardController.expansionStates[absoluteIndex] ?? false,
                    onExpansionChanged: (expanded) {
                      dashboardController.expansionStates[absoluteIndex] = expanded;
                    },
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
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
                        Text(
                          '$completionPercentage%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          final isExpanded = dashboardController.expansionStates[absoluteIndex] ?? false;
                          return TweenAnimationBuilder<double>(
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
                          );
                        }),
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
                            // Task statistics
                            Column(
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
                  ),
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
                        child: Obx(() => DropdownButton<int>(
                          value: dashboardController.itemsPerPage.value,
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
                              dashboardController.itemsPerPage.value = value;
                              dashboardController.currentPage.value = 0;
                            }
                          },
                        )),
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
                      Obx(() => IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed:
                            dashboardController.currentPage.value > 0
                                ? dashboardController.previousPage
                                : null,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              dashboardController.currentPage.value > 0
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.grey.shade200,
                        ),
                      )),
                      const SizedBox(width: 16),
                      Obx(() => Text(
                        'Page ${dashboardController.currentPage.value + 1} of ${dashboardController.totalPages}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                      const SizedBox(width: 16),
                      Obx(() => IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed:
                            dashboardController.currentPage.value <
                                    dashboardController.totalPages - 1
                                ? dashboardController.nextPage
                                : null,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              dashboardController.currentPage.value <
                                      dashboardController.totalPages - 1
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.grey.shade200,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // Helper to build stat row
  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
    Color textColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textColor),
              ),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
}