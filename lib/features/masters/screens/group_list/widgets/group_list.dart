import 'package:doc_sync/features/masters/controllers/group_list_controller.dart';
import 'package:doc_sync/features/masters/models/group_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:doc_sync/features/masters/screens/group_list/widgets/group_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupList extends StatelessWidget {
  final GroupListController groupListController;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const GroupList({
    super.key,
    required this.groupListController,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final groups = groupListController.paginatedGroups;
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: groups.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final group = groups[index];
          return GroupExpansionCard(
            group: group,
            cardBackgroundColor: cardBackgroundColor,
            textColor: textColor,
            subtleTextColor: subtleTextColor,
          );
        },
      );
    });
  }
}

class GroupListShimmer extends StatelessWidget {
  const GroupListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: AppShimmerEffect(
          width: double.infinity,
          height: 80,
          radius: 12,
        ),
      ),
    );
  }
}

class EmptyGroupList extends StatelessWidget {
  const EmptyGroupList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          children: [
            Icon(
              Icons.folder_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No groups found',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
} 