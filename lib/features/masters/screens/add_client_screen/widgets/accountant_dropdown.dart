import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/features/masters/models/accountant_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AccountantDropdown extends StatelessWidget {
  final AddClientController controller;

  const AccountantDropdown({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accountant',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _buildAccountantDropdown(),
      ],
    );
  }

  Widget _buildAccountantDropdown() {
    return Obx(() {
      if (controller.isLoadingAccountants.value) {
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

      return SearchableDropdown<Accountant>(
        label: 'Accountant',
        hint:
            controller.accountants.isEmpty
                ? 'No accountants available'
                : 'Select an accountant',
        items: controller.accountants,
        value: controller.selectedAccountant.value,
        onChanged: (Accountant? newValue) {
          controller.selectedAccountant.value = newValue;
        },
        getLabel: (Accountant accountant) => accountant.name,
        prefixIcon: Icon(Iconsax.user, color: AppColors.textSecondary),
        isLoading: controller.isLoadingAccountants.value,
        enabled: controller.accountants.isNotEmpty,
      );
    });
  }
}
