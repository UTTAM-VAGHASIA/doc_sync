import 'package:flutter/material.dart';

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
  }) {

    return Card(
      elevation: 2,
      shadowColor: Colors.grey.shade50,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        // REMOVED: width: 260, - Expanded will handle the width now
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Important for height within Expanded
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // Allow text to wrap if needed
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: subtleTextColor),
                            maxLines: 2, // Allow subtitle to wrap
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                // Give Icon some padding if text is long and wraps near it
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(icon, size: 30, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            valueWidget,
          ],
        ),
      ),
    );
  }