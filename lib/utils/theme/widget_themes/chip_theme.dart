import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppChipTheme {
  AppChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    checkmarkColor: AppColors.white,
    selectedColor: AppColors.primary,
    disabledColor: AppColors.grey.withValues(alpha: 0.4),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    labelStyle: const TextStyle(color: AppColors.black, fontFamily: 'Nunito'),
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    checkmarkColor: AppColors.white,
    selectedColor: AppColors.primary,
    disabledColor: AppColors.darkerGrey,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    labelStyle: TextStyle(color: AppColors.white, fontFamily: 'Nunito'),
  );
}
