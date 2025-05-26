import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/models/staff_model.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class StaffAllotmentSection extends StatelessWidget {
  const StaffAllotmentSection({super.key, required this.controller});

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
                  'Staff Allotment',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Allotted By Field (Current User)
            _buildAllottedByField(context),

            const SizedBox(height: 16),

            // Allotted To Staff Dropdown with add button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildStaffDropdown(context)),
                const SizedBox(width: 6),
                _buildAddButton(
                  context: context,
                  onTap: () => _showAddStaffDialog(context),
                  tooltip: 'Add new staff',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required BuildContext context,
    required VoidCallback? onTap,
    required String tooltip,
    bool isDisabled = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Icon(
              Icons.add_circle_rounded,
              color: isDisabled ? Colors.grey[600] : AppColors.primary,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllottedByField(BuildContext context) {
    // This field shows the current user as the one who is allotting the task
    return TextFormField(
      readOnly: true,
      initialValue: controller.userName,
      ignorePointers: true,
      decoration: InputDecoration(
        labelText: 'Allotted By',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        prefixIcon: const Icon(Iconsax.user_octagon),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildStaffDropdown(BuildContext context) {
    return Obx(() {
      return SearchableDropdown<Staff>(
        label: 'Allot to Staff',
        hint:
            controller.isLoadingStaff.value
                ? 'Loading staff members...'
                : 'Select staff to allot task',
        items: controller.staffList,
        value: controller.selectedStaff.value,
        onChanged: (Staff? newValue) {
          controller.selectedStaff.value = newValue;
        },
        getLabel: (Staff staff) => staff.staffName,
        prefixIcon: const Icon(Iconsax.profile_2user),
        isLoading: controller.isLoadingStaff.value,
      );
    });
  }

  void _showAddStaffDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            title: const Text('Add New Staff Member'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Staff Name',
                      hintText: 'Enter full name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email address',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter phone number',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    controller.isLoadingStaff.value
                        ? null
                        : () {
                          Navigator.of(context).pop();
                        },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    controller.isLoadingStaff.value
                        ? null
                        : () async {
                          final String name = nameController.text.trim();
                          final String email = emailController.text.trim();
                          final String phone = phoneController.text.trim();
                          final String password =
                              passwordController.text.trim();
                          if (name.isEmpty ||
                              email.isEmpty ||
                              phone.isEmpty ||
                              password.isEmpty) {
                            AppLoaders.warningSnackBar(
                              title: 'Empty Field',
                              message: 'Please fill all fields',
                            );
                            return;
                          }
                          await controller.addStaff(
                            name: name,
                            contact: phone,
                            email: email,
                            password: password,
                          );
                          if (!controller.isLoadingStaff.value &&
                              context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                child:
                    controller.isLoadingStaff.value
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }
}
