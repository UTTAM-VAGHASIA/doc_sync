import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/client_info_section.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/contact_details_section.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/route_header.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/tax_details_section.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';
import 'package:iconsax/iconsax.dart';

class AddClientMobileScreen extends StatelessWidget {
  const AddClientMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddClientController>();

    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Save Draft FAB
          FloatingActionButton(
            heroTag: 'saveDraftFab',
            onPressed: () => controller.saveDraft(),
            backgroundColor: AppColors.secondary,
            mini: true,
            child: const Icon(Iconsax.save_2),
          ),
          const SizedBox(height: 8),
          
          // Submit FAB
          FloatingActionButton(
            heroTag: 'submitFab',
            onPressed: () => controller.submitNewClient(),
            backgroundColor: AppColors.primary,
            child: const Icon(Iconsax.add),
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        key: controller.refreshIndicatorKey,
        onRefresh: () async {
          controller.loadData();
        },
        showChildOpacityTransition: false,
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        height: 100,
        child: Container(
          color: AppColors.lightGrey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RouteHeader(
                  title: 'Add Client',
                  subtitle: 'Home / Masters / Add Client',
                ),

                // Client Information Section
                ClientInfoSection(controller: controller),

                // Contact Details Section
                ContactDetailsSection(controller: controller),

                // Tax Details Section
                TaxDetailsSection(controller: controller),

                // Action Buttons Section
                const SizedBox(height: 32),

                // Primary Action - Submit Client Button
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () =>
                        controller.isSubmitting.value
                            ? AppShimmerEffect(
                                height: 56,
                                width: double.infinity,
                                radius: 12,
                              )
                            : ElevatedButton.icon(
                                onPressed: () => controller.submitNewClient(),
                                icon: const Icon(Iconsax.add_circle),
                                label: Text(
                                  'Add Client',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 16),

                // Secondary Actions Row
                Row(
                  children: [
                    // Save Draft Button
                    Expanded(
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              controller.isSubmitting.value
                                  ? null
                                  : () => controller.saveDraft(),
                          icon: const Icon(Iconsax.save_2, size: 20),
                          label: const Text('Save Draft'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Load Draft Button
                    Expanded(
                      child: Obx(
                        () => ElevatedButton.icon(
                          onPressed:
                              controller.isSubmitting.value
                                  ? null
                                  : () => controller.loadDraft(),
                          icon: const Icon(Iconsax.refresh, size: 20),
                          label: const Text('Load Draft'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppColors.secondary),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Clear Form and Clear Draft Buttons (Tertiary Actions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Obx(
                        () => TextButton.icon(
                          onPressed:
                              controller.isSubmitting.value
                                  ? null
                                  : () => controller.clearForm(),
                          icon: const Icon(Iconsax.trash, size: 18),
                          label: const Text('Clear Form'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(
                        () => TextButton.icon(
                          onPressed:
                              controller.isSubmitting.value
                                  ? null
                                  : () => controller.clearDraft(),
                          icon: const Icon(Iconsax.note_remove, size: 18),
                          label: const Text('Clear Draft'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.black54,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
