import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class DashboardMobileScreen extends StatefulWidget {
  const DashboardMobileScreen({super.key});

  @override
  State<DashboardMobileScreen> createState() => _DashboardMobileScreenState();
}

class _DashboardMobileScreenState extends State<DashboardMobileScreen> {
  final dashboardController = Get.find<DashboardController>();
  
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // This will only fetch if dataAlreadyFetched is false
      dashboardController.fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    // Add this to track expansion state
    final RxMap<int, bool> expansionStates = <int, bool>{}.obs;

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
            Obx(
              () => _buildSummaryCards(
                context: context,
                dashboardController: dashboardController,
                cardBackgroundColor: cardBackgroundColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
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
    // Data for summary cards
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

    // Calculate the width of each card based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns for wider screens, 2 for narrow
    final cardWidth = (screenWidth - (32 + (crossAxisCount - 1) * 8)) / crossAxisCount;
    final cardHeight = cardWidth * 0.8; // Maintain aspect ratio

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() {
        print("Dashboard loading state: ${dashboardController.isLoading.value}");
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemCount: summaryCardsData.length,
          itemBuilder: (context, index) {
            final cardData = summaryCardsData[index];
            
            // Create the value widget based on loading state
            Widget valueDisplay;
            if (dashboardController.isLoading.value) {
              valueDisplay = AppShimmerEffect(width: 64, height: 32);
              print("Creating shimmer for card $index");
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
            
            return _buildEnhancedSummaryCard(
              context: context,
              title: cardData['title'],
              valueWidget: valueDisplay,
              icon: cardData['icon'],
              iconColor: cardData['iconColor'],
              subtitle: cardData['subtitle'],
              cardBackgroundColor: cardBackgroundColor,
              textColor: textColor,
              subtleTextColor: subtleTextColor,
              heroTag: index,
            );
          },
        );
      }),
    );
  }

  // Enhanced summary card design for carousel
  Widget _buildEnhancedSummaryCard({
    required BuildContext context,
    required String title,
    required Widget valueWidget,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
    required int heroTag,
  }) {
    void openExpandedCard() {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (_, __, ___) => _ExpandedSummaryCard(
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

    return Hero(
      tag: 'summary_card_$heroTag',
      child: GestureDetector(
        onLongPress: openExpandedCard,
        child: Card(
          elevation: 3,
          shadowColor: Colors.grey.shade200,
          color: cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: iconColor.withOpacity(0.3), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    GestureDetector(
                      onTap: openExpandedCard,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 28, color: iconColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                valueWidget,
              ],
            ),
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
                  child: Obx(() {
                    final isExpanded =
                        dashboardController.expansionStates[absoluteIndex] ??
                        false;
                    return ExpansionTile(
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        dashboardController.expansionStates[absoluteIndex] =
                            expanded;
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
                      IconButton(
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
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Page ${dashboardController.currentPage.value + 1} of ${dashboardController.totalPages}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
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
                      ),
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
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16,
              ),
            ],
          ],
        ),
        selected: isSelected,
        onSelected: (_) => controller.updateSort(field),
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  // Check that shimmer is working properly
  AppShimmerEffect _buildTestShimmer() {
    return AppShimmerEffect(
      width: 100,
      height: 50,
      radius: 8,
      color: Colors.grey.shade200,
    );
  }
}

// The expanded card page
  class _ExpandedSummaryCard extends StatelessWidget {
    final int heroTag;
    final String title;
    final Widget valueWidget;
    final IconData icon;
    final Color iconColor;
    final String subtitle;
    final Color cardBackgroundColor;
    final Color textColor;
    final Color subtleTextColor;

    const _ExpandedSummaryCard({
      required this.heroTag,
      required this.title,
      required this.valueWidget,
      required this.icon,
      required this.iconColor,
      required this.subtitle,
      required this.cardBackgroundColor,
      required this.textColor,
      required this.subtleTextColor,
    });

    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.black54,
          body: Center(
            child: Hero(
              tag: 'summary_card_$heroTag',
              child: Material(
                color: Colors.transparent,
                child: Card(
                  elevation: 12,
                  color: cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: iconColor.withOpacity(0.3), width: 2),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: iconColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(icon, size: 36, color: iconColor),
                              ),
                            ],
                          ),
                        ),
                        const Flexible(child: SizedBox(height: 20)),
                        Flexible(child: valueWidget),
                        // const Flexible(child: SizedBox(height: 20)),
                        Flexible(child: Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: subtleTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                          textAlign: TextAlign.start,
                        ),)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }