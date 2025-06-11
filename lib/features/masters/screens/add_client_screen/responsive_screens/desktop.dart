import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/client_info_section.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/contact_details_section.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/route_header.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/tax_details_section.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:doc_sync/common/widgets/shimmers/shimmer.dart';

class AddClientDesktopScreen extends StatelessWidget {
  const AddClientDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddClientController>();

    return Scaffold(
      body: Container(
        color: AppColors.lightGrey,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RouteHeader(
              title: 'Add Client',
              subtitle: 'Home / Masters / Add Client',
            ),
            
            const SizedBox(height: 24),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left panel - Form sections
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          // Client Information Section
                          ClientInfoSection(controller: controller),
                          
                          // Contact Details Section
                          ContactDetailsSection(controller: controller),
                          
                          // Tax Details Section
                          TaxDetailsSection(controller: controller),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 24),
                    
                    // Right panel - Action buttons
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Actions',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Add Client Button
                            Obx(() => ElevatedButton.icon(
                              onPressed: controller.isSubmitting.value
                                  ? null
                                  : () => controller.submitNewClient(),
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
                            )),
                            
                            const SizedBox(height: 16),
                            
                            // Save Draft Button
                            Obx(() => ElevatedButton.icon(
                              onPressed: controller.isSubmitting.value
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
                            )),
                            
                            const SizedBox(height: 16),
                            
                            // Load Draft Button
                            Obx(() => ElevatedButton.icon(
                              onPressed: controller.isSubmitting.value
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
                            )),
                            
                            const SizedBox(height: 16),
                            
                            // Clear Form Button
                            Obx(() => TextButton.icon(
                              onPressed: controller.isSubmitting.value
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
                            )),
                            
                            const SizedBox(height: 8),
                            
                            // Clear Draft Button
                            Obx(() => TextButton.icon(
                              onPressed: controller.isSubmitting.value
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
                            )),
                          ],
                        ),
                      ),
                    ),
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