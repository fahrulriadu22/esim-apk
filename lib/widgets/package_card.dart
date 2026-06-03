import 'package:flutter/material.dart';

import '../models/package.dart';

/// Displays a single data package as a tappable card.
///
/// Shows the package name, data amount, validity, price, and relevant
/// badges (5G, Unlimited, Best Seller). Tapping the card fires [onTap].
class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    this.onTap,
  });

  final Package package;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ---------------------------------------------------------------
              // LEFT – Data amount & badges
              // ---------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Badges ---
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (package.supports5G)
                          _Badge(
                            label: '5G',
                            backgroundColor: cs.tertiary,
                            textColor: cs.onTertiary,
                          ),
                        if (package.isUnlimited)
                          _Badge(
                            label: 'UNLIMITED',
                            backgroundColor: cs.primaryContainer,
                            textColor: cs.onPrimaryContainer,
                          ),
                        if (package.isBestSeller)
                          _Badge(
                            label: '⭐ BEST SELLER',
                            backgroundColor: cs.secondaryContainer,
                            textColor: cs.onSecondaryContainer,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // --- Data ---
                    Text(
                      package.isUnlimited
                          ? 'Unlimited'
                          : '${package.data} ${package.dataUnit}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // --- Validity ---
                    Text(
                      '${package.duration} ${_formatDurationUnit(package.durationUnit)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------------------------------------------------------
              // RIGHT – Price & CTA
              // ---------------------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Price ---
                  Text(
                    '€${package.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // --- "Get Plan" button ---
                  FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text('Get Plan'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Converts the duration unit enum/value to a human-readable string.
  String _formatDurationUnit(String unit) {
    switch (unit.toUpperCase()) {
      case 'DAY':
        return 'Days';
      case 'WEEK':
        return 'Weeks';
      case 'MONTH':
        return 'Months';
      case 'YEAR':
        return 'Years';
      default:
        return unit;
    }
  }
}

// =============================================================================
// BADGE HELPER WIDGET
// =============================================================================

/// A small rounded pill used for 5G, UNLIMITED, and BEST SELLER badges.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}