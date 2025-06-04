import 'package:doc_sync/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

// Enhanced summary card design for all screen sizes
Widget buildSummaryCard({
  required BuildContext context,
  required String title,
  required Widget valueWidget,
  required IconData icon,
  required Color iconColor,
  required String subtitle,
  required Color cardBackgroundColor,
  required Color textColor,
  required Color subtleTextColor,
  int? heroTag, // Optional hero tag for mobile animation
  VoidCallback? onTap, // Optional tap callback for mobile
}) {
  // Determine if we're on mobile based on screen width
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;
  
  // Create the card content
  Widget cardContent = Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              Container(
                padding: EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(icon, size: 28, color: iconColor)),
              ),
            ],
          ),
        ),
        Flexible(child: const SizedBox(height: 12)),
        valueWidget,
        
        if (!isMobile) ...[
          Flexible(child: const SizedBox(height: 8)),
          Flexible(
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: subtleTextColor,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    ),
  );
  
  // Create the card with or without hero animation
  if (isMobile && heroTag != null) {
    return Hero(
      tag: 'summary_card_$heroTag',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onTap,
        child: Card(
          elevation: 3,
          shadowColor: Colors.grey.shade200,
          color: cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: iconColor.withOpacity(0.3), width: 1.5),
          ),
          child: cardContent,
        ),
      ),
    );
  } else {
    return Card(
      elevation: 3,
      shadowColor: Colors.grey.shade200,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: iconColor.withOpacity(0.3), width: 1.5),
      ),
      child: cardContent,
    );
  }
}

// The expanded card page for mobile only
class ExpandedSummaryCard extends StatelessWidget {
  final int heroTag;
  final String title;
  final Widget valueWidget;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final Color cardBackgroundColor;
  final Color textColor;
  final Color subtleTextColor;

  const ExpandedSummaryCard({
    super.key,
    required this.heroTag,
    required this.title,
    required this.valueWidget,
    required this.icon,
    required this.iconColor,
    required this.subtitle,
    required this.cardBackgroundColor,
    required this.textColor,
    required this.subtleTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: Center(
          child: Hero(
            tag: 'summary_card_$heroTag',
            child: Material(
              color: Colors.transparent,
              child: Card(
                elevation: 12,
                color: cardBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: iconColor.withOpacity(0.3), width: 2),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, size: 36, color: iconColor),
                          ),
                        ],
                      ),
                      Flexible(child: const SizedBox(height: 20)),
                      Flexible(child: valueWidget),
                      Flexible(child: const SizedBox(height: 16)),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: subtleTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}