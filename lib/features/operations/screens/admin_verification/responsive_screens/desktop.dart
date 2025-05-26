import 'package:doc_sync/features/operations/controllers/admin_verification_controller.dart';
import 'package:doc_sync/features/operations/screens/admin_verification/responsive_screens/mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminVerificationDesktopScreen extends StatelessWidget {
  const AdminVerificationDesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminVerificationController>();
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Verification',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: const AdminVerificationMobileScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 