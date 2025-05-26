import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/models/client_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ClientSelectionSection extends StatelessWidget {
  const ClientSelectionSection({super.key, required this.controller});

  final NewTaskController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Client Selection',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Client Dropdown with add button
            _buildClientDropdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown(BuildContext context) {
    return Obx(() {
      return SearchableDropdown<Client>(
        label: 'Client',
        hint:
            controller.isLoadingClients.value
                ? 'Loading clients...'
                : 'Select a client',
        items: controller.clients,
        value: controller.selectedClient.value,
        onChanged: (Client? newValue) {
          controller.selectedClient.value = newValue;
        },
        getLabel: (Client client) => '${client.firmName} (${client.fileNo})',
        prefixIcon: const Icon(Iconsax.user),
        isLoading: controller.isLoadingClients.value,
      );
    });
  }
}
