import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/group_dropdown.dart';
import 'package:doc_sync/features/masters/screens/add_client_screen/widgets/accountant_dropdown.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ClientInfoSection extends StatelessWidget {
  final AddClientController controller;

  const ClientInfoSection({
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
              'Client Information',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // File Number
            _buildTextField(
              context: context,
              label: 'File Number',
              hint: 'Enter file number',
              onChanged: (value) => controller.fileNo.value = value,
              value: controller.fileNo,
              keyboardType: TextInputType.text,
              icon: Iconsax.document_1,
            ),
            const SizedBox(height: 16),
            
            // Firm Name
            _buildTextField(
              context: context,
              label: 'Firm Name',
              hint: 'Enter firm name',
              onChanged: (value) => controller.firmName.value = value,
              value: controller.firmName,
              keyboardType: TextInputType.text,
              icon: Iconsax.building,
            ),
            const SizedBox(height: 16),
            
            // Contact Person
            _buildTextField(
              context: context,
              label: 'Contact Person',
              hint: 'Enter contact person name',
              onChanged: (value) => controller.contactPerson.value = value,
              value: controller.contactPerson,
              keyboardType: TextInputType.name,
              icon: Iconsax.user,
            ),
            const SizedBox(height: 16),
            
            // Group Dropdown
            GroupDropdown(controller: controller),
            
            const SizedBox(height: 16),
            
            // Accountant Dropdown
            AccountantDropdown(controller: controller),
            
            // // Status
            // _buildDropdownField(
            //   context: context,
            //   label: 'Status',
            //   value: controller.status,
            //   items: ['Active', 'Inactive'],
            //   onChanged: (value) {
            //     if (value != null) controller.status.value = value;
            //   },
            //   icon: Iconsax.status,
            // ),
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

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required RxString value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    bool isRequired = false,
  }) {
    return Obx(() => InputDecorator(
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: AppColors.textSecondary),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(
          color: isRequired ? Colors.grey.shade300 : null,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.value,
          isDense: true,
          onChanged: onChanged,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    ));
  }
} 