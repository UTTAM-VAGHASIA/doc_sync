import 'package:doc_sync/common/widgets/searchable_dropdown.dart';
import 'package:doc_sync/features/operations/controllers/new_task_controller.dart';
import 'package:doc_sync/features/operations/models/financial_year.dart';
import 'package:doc_sync/utils/constants/colors.dart';
import 'package:doc_sync/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';

class FinancialYearSection extends StatelessWidget {
  const FinancialYearSection({super.key, required this.controller});

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
                  'Period Selection',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Financial Year Dropdown with add button
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildFinancialYearDropdown(context)),
                const SizedBox(width: 6),
                _buildAddButton(
                  context: context,
                  onTap: () => _showAddFinancialYearDialog(context),
                  tooltip: 'Add new financial year',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Month Range Selection (From and To)
            _buildMonthSelectionRow(context),
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

  Widget _buildFinancialYearDropdown(BuildContext context) {
    return Obx(() {
      return SearchableDropdown<FinancialYear>(
        label: 'Financial Year',
        hint:
            controller.isLoadingFinancialYears.value
                ? 'Loading financial years...'
                : 'Select financial year',
        items: controller.financialYears,
        value: controller.selectedFinancialYear.value,
        onChanged: (FinancialYear? newValue) {
          controller.selectedFinancialYear.value = newValue;
        },
        getLabel: (FinancialYear year) => year.financial_year,
        prefixIcon: const Icon(Iconsax.calendar_1),
        isLoading: controller.isLoadingFinancialYears.value,
      );
    });
  }

  Widget _buildMonthSelectionRow(BuildContext context) {
    return Column(
      children: [
        // From Month Dropdown
        _buildMonthDropdown(
          context,
          'From Month',
          controller.selectedFromMonth,
          (String? newValue) {
            controller.selectedFromMonth.value = newValue;
            if (controller.selectedToMonth.value == null) {
              controller.selectedToMonth.value = newValue;
            }
          },
        ),

        const SizedBox(height: 16),

        // To Month Dropdown
        _buildMonthDropdown(context, 'To Month', controller.selectedToMonth, (
          String? newValue,
        ) {
          controller.selectedToMonth.value = newValue;
        }),
      ],
    );
  }

  Widget _buildMonthDropdown(
    BuildContext context,
    String label,
    Rx<String?> selectedValue,
    Function(String?) onChanged,
  ) {
    return Obx(() {
      return SearchableDropdown<String>(
        label: label,
        hint: 'Select month',
        items: controller.months,
        value: selectedValue.value,
        onChanged: onChanged,
        getLabel: (String month) => month,
        prefixIcon: const Icon(Iconsax.calendar),
      );
    });
  }

  void _showAddFinancialYearDialog(BuildContext context) {
    final TextEditingController startYearController = TextEditingController();
    final TextEditingController endYearController = TextEditingController();
    final RxInt formatOption = 0.obs; // 0: Default, 1: Full

    Future<void> pickYear({
      required TextEditingController controller,
      required String label,
    }) async {
      final picked = await showDialog<int>(
        context: context,
        builder: (context) {
          // Remove extra lines by using Material and no padding
          return Dialog(
            backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  secondary: AppColors.primary,
                  onSurface: AppColors.primary,
                ),
                textTheme: Theme.of(context).textTheme.copyWith(
                  bodyMedium: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.primary),
                  titleMedium: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.primary),
                ),
              ),
              child: SizedBox(
                width: 300,
                height: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: YearPicker(
                    firstDate: DateTime(DateTime.now().year - 100, 1),
                    lastDate: DateTime(DateTime.now().year + 100, 1),
                    selectedDate: DateTime.now(),
                    onChanged: (date) {
                      Navigator.of(context).pop(date.year);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
      if (picked != null) {
        controller.text = picked.toString();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            title: const Text('Add New Financial Year'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: startYearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: 'Start Year',
                          hintText: 'e.g., 2023',
                          counterText: '',
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.calendar),
                            onPressed: () => pickYear(
                              controller: startYearController,
                              label: 'Start Year',
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'\d{0,4}')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: endYearController,
                        keyboardType: TextInputType.number,
                        maxLength: formatOption.value == 0 ? 4 : 4,
                        decoration: InputDecoration(
                          labelText: 'End Year',
                          hintText: formatOption.value == 0
                              ? 'e.g., 26 or 2026'
                              : 'e.g., 2026',
                          counterText: '',
                          suffixIcon: IconButton(
                            icon: const Icon(Iconsax.calendar),
                            onPressed: () => pickYear(
                              controller: endYearController,
                              label: 'End Year',
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'\d{0,4}'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => Radio<int>(
                            value: 0,
                            groupValue: formatOption.value,
                            onChanged: (v) => formatOption.value = v!,
                          ),
                        ),
                        const Text('Default (2024-26)'),
                      ],
                    ),
                    Row(
                      children: [
                        Obx(
                          () => Radio<int>(
                            value: 1,
                            groupValue: formatOption.value,
                            onChanged: (v) => formatOption.value = v!,
                          ),
                        ),
                        const Text('Full (2024-2026)'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: controller.isLoadingFinancialYears.value
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: controller.isLoadingFinancialYears.value
                    ? null
                    : () async {
                        final String startYear = startYearController.text.trim();
                        String endYear = endYearController.text.trim();

                        if (startYear.isEmpty || endYear.isEmpty) {
                          AppLoaders.warningSnackBar(
                            title: 'Empty Fields',
                            message: 'Please enter both start and end year',
                          );
                          return;
                        }
                        if (startYear.length != 4 ||
                            int.tryParse(startYear) == null) {
                          AppLoaders.warningSnackBar(
                            title: 'Invalid Input',
                            message: 'Start year must be a valid 4-digit number',
                          );
                          return;
                        }

                        // Parse and validate end year based on format
                        String formattedEndYear = endYear;
                        if (formatOption.value == 0) {
                          // Default: 2-digit end year, but allow 4-digit input
                          if (endYear.length == 4 && int.tryParse(endYear) != null) {
                            // If user entered 2026, convert to 26
                            formattedEndYear = endYear.substring(2, 4);
                          } else if (endYear.length == 2 && int.tryParse(endYear) != null) {
                            // Already 2 digits, use as is
                            formattedEndYear = endYear;
                          } else {
                            AppLoaders.warningSnackBar(
                              title: 'Invalid Input',
                              message: 'End year must be a valid 2 or 4-digit number',
                            );
                            return;
                          }
                          // Check that end year is after start year
                          int start = int.parse(startYear);
                          int endFull = int.tryParse(endYear.length == 2
                              ? startYear.substring(0, 2) + endYear
                              : endYear) ?? 0;
                          if (endFull <= start) {
                            AppLoaders.warningSnackBar(
                              title: 'Invalid Range',
                              message: 'End year must be after start year',
                            );
                            return;
                          }
                        } else {
                          // Full: 4-digit end year
                          if (endYear.length == 2 && int.tryParse(endYear) != null) {
                            // If user entered 26, convert to 2026 (use start year prefix)
                            formattedEndYear = startYear.substring(0, 2) + endYear;
                          } else if (endYear.length == 4 && int.tryParse(endYear) != null) {
                            formattedEndYear = endYear;
                          } else {
                            AppLoaders.warningSnackBar(
                              title: 'Invalid Input',
                              message: 'End year must be a valid 2 or 4-digit number',
                            );
                            return;
                          }
                          if (int.parse(formattedEndYear) <= int.parse(startYear)) {
                            AppLoaders.warningSnackBar(
                              title: 'Invalid Range',
                              message: 'End year must be after start year',
                            );
                            return;
                          }
                        }

                        await controller.addFinancialYear(
                          startYear: startYear,
                          endYear: formattedEndYear,
                        );
                        if (!controller.isLoadingFinancialYears.value &&
                            context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                child: controller.isLoadingFinancialYears.value
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
