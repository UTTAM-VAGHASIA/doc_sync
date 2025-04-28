import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class RouteHeader extends StatelessWidget {
  const RouteHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;
  final Color subtleTextColor = AppColors.textSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: subtleTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          // Optionally, add an avatar or icon here for extra polish
        ],
      ),
    );
  }
}