import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:doc_sync/utils/constants/api_constants.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/constants/sizes.dart';

/// A completely self-contained dialog that doesn't rely on external controllers
class OrganizationDialogService {
  static Future<void> showOrganizationDialog({
    final bool isForced = false,
  }) async {
    await Get.dialog(
      OrganizationDialog(isForced: isForced),
      barrierDismissible: false,
    );
  }
}

class OrganizationDialog extends StatefulWidget {
  final bool isForced;

  const OrganizationDialog({
    super.key,
    this.isForced = false,
  });

  @override
  State<OrganizationDialog> createState() => _OrganizationDialogState();
}

class _OrganizationDialogState extends State<OrganizationDialog> {
  late final TextEditingController textController;
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
    // Initialize with current organization
    textController.text = ApiConstants().organization;
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // Function to validate organization name
  String? validateOrganization(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Organization name is required';
    }
    if (value.trim().contains(' ')) {
      return 'Organization name cannot contain spaces';
    }
    return null;
  }

  // Function to save organization
  Future<void> saveOrganization() async {
    if (formKey.currentState!.validate()) {
      final newOrganization = textController.text.trim().toLowerCase();

      isLoading.value = true;

      try {
        // Change the organization with the async method
        await ApiConstants().changeOrganization(newOrganization);

        // Close dialog and show success message
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        Get.snackbar(
          'Success',
          'Organization changed to $newOrganization',
          margin: const EdgeInsets.all(AppSizes.md),
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
        );
      } catch (e) {
        // Handle any errors that might occur
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Failed to change organization: $e',
          margin: const EdgeInsets.all(AppSizes.md),
          snackStyle: SnackStyle.FLOATING,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading.value && !widget.isForced,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        ),
        backgroundColor: AppColors.white,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Icon
                  Icon(
                    Iconsax.building_4,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Title
                  Text(
                    "Change Organization",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Description
                  Text(
                    "Enter the name of your organization",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizes.fontSizeMd,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Form
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: textController,
                      validator: validateOrganization,
                      enabled: !isLoading.value,
                      decoration: InputDecoration(
                        labelText: "Organization",
                        hintText: "Enter organization name",
                        prefixIcon: Icon(
                          Iconsax.building,
                          color: AppColors.primary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputFieldRadius,
                          ),
                          borderSide: BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputFieldRadius,
                          ),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.inputFieldRadius,
                          ),
                          borderSide: BorderSide(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      if (!widget.isForced)
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isLoading.value ? null : () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSizes.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.buttonRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                      if (!widget.isForced) const SizedBox(width: AppSizes.md),

                      // Submit Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              isLoading.value ? null : saveOrganization,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSizes.md,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.buttonRadius,
                              ),
                            ),
                          ),
                          child:
                              isLoading.value
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                  : Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
