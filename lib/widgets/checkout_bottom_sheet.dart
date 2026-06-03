import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/location.dart';
import '../models/package.dart';

/// A bottom sheet that shows a summary of the selected plan and prompts
/// the user to continue to the external website (Safari / Chrome) to
/// finalise the purchase.
///
/// **Apple Compliance:**
/// - No WebView is used — [url_launcher] opens the system browser.
/// - The button says "Continue to Website", never "Buy Now".
/// - The user always sees a confirmation step before leaving the app.
class CheckoutBottomSheet extends StatelessWidget {
  const CheckoutBottomSheet({
    super.key,
    required this.country,
    required this.package,
  });

  /// The country (or region) the user selected.
  final Location country;

  /// The data package the user wants to acquire.
  final Package package;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    // Build a deep-link / purchase URL for the external website.
    // In production this would point to the actual checkout page.
    final String checkoutUrl = _buildCheckoutUrl();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------------------------------------------------------------------
          // DRAG HANDLE
          // -------------------------------------------------------------------
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // TITLE
          // -------------------------------------------------------------------
          Text(
            'Confirm Your Plan',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will be redirected to our secure website to complete your purchase.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // -------------------------------------------------------------------
          // SUMMARY CARD
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withAlpha(128)),
            ),
            child: Column(
              children: [
                // Country
                _SummaryRow(
                  label: 'Country',
                  value: '${country.flag} ${country.name}',
                  cs: cs,
                ),
                const Divider(height: 20),

                // Plan
                _SummaryRow(
                  label: 'Plan',
                  value: package.isUnlimited
                      ? 'Unlimited'
                      : '${package.data} ${package.dataUnit}',
                  cs: cs,
                ),
                const Divider(height: 20),

                // Validity
                _SummaryRow(
                  label: 'Validity',
                  value: '${package.duration} ${_formatDurationUnit(package.durationUnit)}',
                  cs: cs,
                ),
                const Divider(height: 20),

                // Price
                _SummaryRow(
                  label: 'Price',
                  value: '€${package.price.toStringAsFixed(2)}',
                  cs: cs,
                  isHighlighted: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // -------------------------------------------------------------------
          // CONTINUE TO WEBSITE BUTTON
          // -------------------------------------------------------------------
          FilledButton.icon(
            onPressed: () => _launchUrl(context, checkoutUrl),
            icon: const Icon(Icons.open_in_browser, size: 20),
            label: const Text('Continue to Website'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // CANCEL
          // -------------------------------------------------------------------
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(height: 8),

          // -------------------------------------------------------------------
          // FOOTER NOTE (Apple compliance reassurance)
          // -------------------------------------------------------------------
          Text(
            'You will be redirected to an external browser (Safari/Chrome) '
            'to finalise your plan securely.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------


  /// Builds the external URL for the package checkout page.
  String _buildCheckoutUrl() {
    // In a real implementation this would point to the production website
    // with the package code and country code as query parameters.
    return 'https://esim-marketplace.com/checkout'
        '?country=${Uri.encodeComponent(country.code)}'
        '&package=${Uri.encodeComponent(package.code)}';
  }

  /// Opens [url] in the system browser (Safari on iOS, Chrome on Android).
  Future<void> _launchUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Dismiss the bottom sheet after launching
      if (context.mounted) Navigator.of(context).pop();
    } else {
      // Show a snackbar if the URL cannot be opened.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not open website. Please try again later.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Converts the duration unit to a human-readable string.
  String _formatDurationUnit(String unit) {
    switch (unit.toUpperCase()) {
      case 'DAY':
        return 'Days';
      case 'WEEK':
        return 'Weeks';
      case 'MONTH':
        return 'Months';
      default:
        return unit;
    }
  }
}

// =============================================================================
// SUMMARY ROW HELPER
// =============================================================================

/// A single row inside the summary card showing a label on the left and a
/// value on the right.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.cs,
    this.isHighlighted = false,
  });

  final String label;
  final String value;
  final ColorScheme cs;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
            color: isHighlighted ? cs.primary : cs.onSurface,
          ),
        ),
      ],
    );
  }
}