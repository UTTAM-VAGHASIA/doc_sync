import 'package:doc_sync/features/masters/controllers/add_client_controller.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TaxDetailsSection extends StatelessWidget {
  final AddClientController controller;

  const TaxDetailsSection({
    super.key,
    required this.controller,
  });

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
              'Tax Information',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // PAN
            _buildTextField(
              context: context,
              label: 'PAN',
              hint: 'Enter PAN',
              onChanged: (value) => controller.pan.value = value,
              value: controller.pan,
              keyboardType: TextInputType.text,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
              icon: Iconsax.card,
              helperText: 'Enter 10-character PAN',
            ),
            const SizedBox(height: 20),
            
            // GSTN
            _buildTextField(
              context: context,
              label: 'GSTN',
              hint: 'Enter GSTN',
              onChanged: (value) => controller.gstn.value = value,
              value: controller.gstn,
              keyboardType: TextInputType.text,
              maxLength: 15,
              icon: Iconsax.receipt_2,
              helperText: 'Enter 15-character GSTN',
            ),
            const SizedBox(height: 20),
            
            // TAN
            _buildTextField(
              context: context,
              label: 'TAN',
              hint: 'Enter TAN',
              onChanged: (value) => controller.tan.value = value,
              value: controller.tan,
              keyboardType: TextInputType.text,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                UpperCaseTextFormatter(),
              ],
              icon: Iconsax.document_code,
            ),
            const SizedBox(height: 20),
            
            // Other ID
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _buildTextField(
                    context: context,
                    label: 'Other ID',
                    hint: 'Enter any other ID',
                    onChanged: (value) => controller.otherId.value = value,
                    value: controller.otherId,
                    keyboardType: TextInputType.text,
                    icon: Iconsax.card_add,
                  ),
                ),
                const SizedBox(width: 6),
                _buildAddButton(
                  context: context,
                  onTap: () {
                    // Placeholder for adding another ID
                    // This would typically open a dialog or add a new field
                  },
                  tooltip: 'Add another ID',
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

// Custom text formatter to convert text to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
} 