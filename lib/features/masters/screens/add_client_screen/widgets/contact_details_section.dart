import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ContactDetailsSection extends StatelessWidget {
  final AddClientController controller;

  const ContactDetailsSection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
            Text(
              'Contact Details',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Email
            _buildTextField(
              context: context,
              label: 'Email Address',
              hint: 'Enter email address',
              onChanged: (value) => controller.email.value = value,
              value: controller.email,
              keyboardType: TextInputType.emailAddress,
              icon: Iconsax.sms,
            ),
            const SizedBox(height: 20),
            
            // Contact Number
            _buildTextField(
              context: context,
              label: 'Contact Number',
              hint: 'Enter contact number',
              onChanged: (value) => controller.contactNo.value = value,
              value: controller.contactNo,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              icon: Iconsax.call,
              helperText: 'Enter 10-digit mobile number',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required Function(String) onChanged,
    required RxString value,
    required TextInputType keyboardType,
    required IconData icon,
    String? helperText,
    bool isRequired = false,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    // Create a controller instance that persists between rebuilds
    final textController = TextEditingController(text: value.value);

    return Obx(() {
      // Only update the text if it differs from the controller's text
      if (textController.text != value.value) {
        final previousCursor = textController.selection;
        textController.text = value.value;

        // Try to maintain the cursor position if possible
        if (previousCursor.start <= textController.text.length) {
          textController.selection = previousCursor;
        }
      }

      return TextFormField(
        controller: textController,
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hint,
          counterText: '',
          helperText: helperText,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Icon(icon, color: AppColors.textSecondary),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: TextStyle(
            color: isRequired ? Colors.redAccent : null,
          ),
        ),
        onChanged: onChanged,
      );
    });
  }
} 