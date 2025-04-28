import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }