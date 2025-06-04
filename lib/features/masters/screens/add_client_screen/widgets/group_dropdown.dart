import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/features/masters/models/group_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class GroupDropdown extends StatelessWidget {
  final AddClientController controller;

  const GroupDropdown({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group',
          style: TextStyle(
            fontSize: 14,
              fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildGroupDropdown(),
      ],
    );
  }

  Widget _buildGroupDropdown() {
    return Obx(() {
      if (controller.isLoadingGroups.value) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey[50],
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      }

      return SearchableDropdown<Group>(
        label: 'Group',
        hint: controller.groups.isEmpty 
            ? 'No groups available' 
            : 'Select a group',
        items: controller.groups,
        value: controller.selectedGroup.value,
        onChanged: (Group? newValue) {
          controller.selectedGroup.value = newValue;
        },
        getLabel: (Group group) => group.groupName,
        prefixIcon: Icon(Iconsax.profile_2user, color: AppColors.textSecondary),
        isLoading: controller.isLoadingGroups.value,
        enabled: controller.groups.isNotEmpty,
      );
    });
  }
} 