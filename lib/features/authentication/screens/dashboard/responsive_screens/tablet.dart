import 'package:data_table_2/data_table_2.dart';
import 'package:doc_sync/common/widgets/data_table/paginated_data_table.dart';
import 'package:doc_sync/features/authentication/controllers/dashboard_controller.dart';
import 'package:doc_sync/features/authentication/models/dashboard_table_data_source.dart';
import 'package:doc_sync/features/authentication/screens/dashboard/widgets/responsive_card_grid.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';

class DashboardTabletScreen extends StatefulWidget {
  const DashboardTabletScreen({super.key});

  @override
  State<DashboardTabletScreen> createState() => _DashboardTabletScreenState();
}

class _DashboardTabletScreenState extends State<DashboardTabletScreen> {
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
    // Using a primary color similar to the image, adjust as needed
    final Color cardBackgroundColor = AppColors.white;
    final Color textColor = AppColors.textPrimary;
    final Color subtleTextColor = AppColors.textSecondary;

    return LiquidPullToRefresh(
      animSpeedFactor: 2.3,
      color: AppColors.primary,
      backgroundColor: AppColors.light,
      showChildOpacityTransition: false,
      onRefresh: () => dashboardController.refreshDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        hitTestBehavior: HitTestBehavior.translucent,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Greeting and route info ---
            Padding(
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: subtleTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  // Optionally, add an avatar or icon here for extra polish
                ],
              ),
            ),
            // --- Top Summary Cards ---
            // --- Responsive Summary Card Grid ---
            Obx(
              () => buildResponsiveCardGrid(
                context: context,
                cardsData: [
                  dashboardController.todayCreated.value,
                  dashboardController.todayCompleted.value,
                  dashboardController.todayPending.value,
                  dashboardController.totalPending.value,
                  dashboardController.totalTasks.value,
                  dashboardController.runningLate.value,
                ],
                crossAxisCount: 2,
                cardBackgroundColor: cardBackgroundColor,
                textColor: textColor,
                subtleTextColor: subtleTextColor,
                isLoading: dashboardController.isLoading.value,
              ),
            ),

            const SizedBox(height: 30), // Spacing between cards and table
            // --- Work Flow Table Section ---
            Card(
              elevation: 2,
              shadowColor: Colors.grey.shade50,
              color: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header Row (Title, Entries, Search)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Work Flow | Over-all',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (dashboardController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return AppPaginatedDataTable(
                        tableHeight: 600,
                        sortAscending: true,
                        columns: const [
                          DataColumn2(label: Text('Sr.\nNo.')),
                          DataColumn2(label: Text('Emp\nName')),
                          DataColumn2(label: Text('Pending\nTasks')),
                          DataColumn2(label: Text('Completed\nTasks')),
                          DataColumn2(label: Text('Alloted\nTasks')),
                          DataColumn2(label: Text('Re-Alloted\nTasks')),
                          DataColumn2(label: Text('Awaiting\nClient')),
                          DataColumn2(label: Text('Total\nRemaining')),
                          DataColumn2(label: Text('Total\nTasks')),
                        ],
                        source: DashboardTableData(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
