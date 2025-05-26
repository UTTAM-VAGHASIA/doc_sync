import 'package:doc_sync/common/widgets/layout/templates/site_layout.dart';
import 'package:doc_sync/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imagePath;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.subtitle,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SiteLayoutTemplate(
      mobile: _PlaceholderContent(
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
      ),
      desktop: _PlaceholderContent(
        title: title,
        subtitle: subtitle,
        imagePath: imagePath,
      ),
    );
  }
}

class _PlaceholderContent extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imagePath;

  const _PlaceholderContent({
    required this.title,
    this.subtitle,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final defaultSubtitle = 'This feature is still being developed. Our team is working hard to complete it and it will be available in future updates. Thank you for your patience.';
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              Image.asset(
                imagePath!,
                width: 240,
                height: 240,
              ),
              const SizedBox(height: 40),
            ],
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle ?? defaultSubtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 