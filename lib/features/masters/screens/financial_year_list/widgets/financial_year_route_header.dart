import 'package:doc_sync/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class FinancialYearRouteHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAddPressed;

  const FinancialYearRouteHeader({
    super.key, 
    required this.title, 
    required this.subtitle, 
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Title and subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // Right side - Add button
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onAddPressed,
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
            tooltip: 'Add Financial Year',
          ),
        ),
      ],
    );
  }
} 