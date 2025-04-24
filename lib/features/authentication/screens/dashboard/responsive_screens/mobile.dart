import 'package:carousel_slider/carousel_slider.dart';
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/models/dashboard_table_item_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class DashboardMobileScreen extends StatelessWidget {
  const DashboardMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = DashboardController.instance;
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    return LiquidPullToRefresh(
      animSpeedFactor: 2.3,
      color: AppColors.primary,
      backgroundColor: AppColors.light,
      showChildOpacityTransition: false,
      onRefresh: () => dashboardController.fetchDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        hitTestBehavior: HitTestBehavior.translucent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Greeting and route info ---
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
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
                            'Welcome, ${dashboardController.userController.user.value.name}!',
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              () => _buildSummaryCardsCarousel(
                context: context,
                dashboardController: dashboardController,
                cardBackgroundColor: cardBackgroundColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
              ),
            ),
            
            // Progress indicator for carousel
            Center(
              child: Obx(
                () => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    6, // Number of cards
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dashboardController.currentCarouselIndex.value == index
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
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
  Widget _buildSummaryCardsCarousel({
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

    return CarouselSlider.builder(
      itemCount: summaryCardsData.length,
      options: CarouselOptions(
        height: 180,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        enableInfiniteScroll: true,
        autoPlay: false,
        onPageChanged: (index, reason) {
          dashboardController.currentCarouselIndex.value = index;
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final cardData = summaryCardsData[index];
        return _buildEnhancedSummaryCard(
          context: context,
          title: cardData['title'],
          value: cardData['value'],
          icon: cardData['icon'],
          iconColor: cardData['iconColor'],
          subtitle: cardData['subtitle'],
          cardBackgroundColor: cardBackgroundColor,
          textColor: textColor,
          subtleTextColor: subtleTextColor,
        );
      },
    );
  }

  // Enhanced summary card design for carousel
  Widget _buildEnhancedSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required String subtitle,
    required Color cardBackgroundColor,
    required Color textColor,
    required Color subtleTextColor,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey.shade200,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: iconColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
            Flexible(child: const SizedBox(height: 16)),
            Flexible(
              child: Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ),
            Flexible(child: const SizedBox(height: 8)),
            Flexible(
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtleTextColor,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardController.tableItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        // Get employee data from data source
        final item = dashboardController.tableItems[index];
        
        // Calculate totals
        final int totalRemaining = (item.pending ?? 0) + 
                                  (item.alloted ?? 0) + 
                                  (item.reAlloted ?? 0) + 
                                  (item.awaitingClient ?? 0);
                                  
        final int totalTasks = totalRemaining + (item.completed ?? 0);
        
        // Calculate completion percentage
        final completionPercentage = totalTasks > 0 
            ? ((item.completed ?? 0) / totalTasks * 100).toInt() 
            : 0;
        
        // Determine status color
        Color statusColor = Colors.green;
        if ((item.pending ?? 0) > 0) {
          statusColor = Colors.orange;
        }
        if (totalRemaining > 5) {
          statusColor = Colors.red;
        }
        
        // Create expandable employee card
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              childrenPadding: const EdgeInsets.only(
                left: 16, 
                right: 16, 
                bottom: 16,
              ),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 8,
              ),
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
                        '${index + 1}',
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
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$completionPercentage%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: subtleTextColor,
                  ),
                ],
              ),
              children: [
                const SizedBox(height: 8),
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
        );
      },
    );
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
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                ),
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
        if (!isLast)
          Divider(
            color: Colors.grey.shade200,
            height: 1,
          ),
      ],
    );
  }
}

// Add to your pubspec.yaml:
// dependencies:
//   carousel_slider: ^4.2.1