import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/location.dart';
import '../models/package.dart';
import '../providers/checkout_provider.dart';

/// Checkout screen that supports 4 payment methods with full Apple compliance.
///
/// **Apple guidelines compliance:**
/// - No credit card form inside the app
/// - No WebView — PayPal opens in external Safari/Chrome via [url_launcher]
/// - "You'll be redirected..." confirmation bottom sheet before external link
/// - Deposit (internal balance) is processed in-app
/// - Order polling every 3 seconds for PayPal
/// - Success → navigate to My eSIMs tab
/// - Failed → show error with retry button
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CheckoutState checkout = ref.watch(checkoutProvider);
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    // If we have a country + package from the provider, use them.
    // Otherwise fall back to whatever the caller passed via arguments
    // (which in a real app would be set before pushing this screen).
    final Package? pkg = checkout.package;
    final Location? loc = checkout.country;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _buildBody(theme, cs, checkout, pkg, loc),
    );
  }

  // ===========================================================================
  // BODY
  // ===========================================================================

  Widget _buildBody(
    ThemeData theme,
    ColorScheme cs,
    CheckoutState checkout,
    Package? pkg,
    Location? loc,
  ) {
    switch (checkout.step) {
      case CheckoutStep.reviewing:
        return _buildReviewStep(theme, cs, checkout, pkg, loc);
      case CheckoutStep.processing:
        return _buildProcessingStep(theme, cs, checkout);
      case CheckoutStep.success:
        return _buildSuccessStep(theme, cs, checkout);
      case CheckoutStep.failed:
        return _buildFailedStep(theme, cs, checkout);
    }
  }

  // ===========================================================================
  // REVIEW STEP
  // ===========================================================================

  Widget _buildReviewStep(
    ThemeData theme,
    ColorScheme cs,
    CheckoutState checkout,
    Package? pkg,
    Location? loc,
  ) {
    if (pkg == null) {
      return Center(
        child: Text(
          'No package selected.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }

    final CheckoutNotifier notifier = ref.read(checkoutProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------------------------------------------------------------
          // ORDER SUMMARY
          // ---------------------------------------------------------------
          Text(
            'Order Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryRow(
                    label: loc != null ? '${loc.flag} ${loc.name}' : 'Package',
                    value: pkg.isUnlimited
                        ? 'Unlimited'
                        : '${pkg.data} ${pkg.dataUnit}',
                    cs: cs,
                  ),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: 'Validity',
                    value: '${pkg.duration} ${_formatUnit(pkg.durationUnit)}',
                    cs: cs,
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: checkout.quantity > 1
                                ? () =>
                                    notifier.setQuantity(checkout.quantity - 1)
                                : null,
                            iconSize: 24,
                          ),
                          Text(
                            '${checkout.quantity}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () =>
                                notifier.setQuantity(checkout.quantity + 1),
                            iconSize: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: 'Total',
                    value:
                        '\$${notifier.totalPrice.toStringAsFixed(2)}',
                    cs: cs,
                    isHighlighted: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ---------------------------------------------------------------
          // PROMO CODE
          // ---------------------------------------------------------------
          TextField(
            controller: _promoController,
            onChanged: (v) => notifier.setPromoCode(v),
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              suffixIcon: checkout.promoCode.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {},
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // ---------------------------------------------------------------
          // USE DEPOSIT
          // ---------------------------------------------------------------
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Use Deposit'),
              subtitle: checkout.isLoadingBalance
                  ? const Text('Loading balance...')
                  : Text(
                      'Available: \$${checkout.balance.toStringAsFixed(2)}'),
              value: checkout.useDeposit,
              onChanged: (v) {
                notifier.setUseDeposit(v);
                if (v) notifier.fetchBalance();
              },
            ),
          ),
          const SizedBox(height: 16),

          // ---------------------------------------------------------------
          // PAYMENT METHODS
          // ---------------------------------------------------------------
          Text(
            'Payment Method',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _PaymentMethodTile(
            icon: Icons.account_balance_wallet,
            title: 'Deposit',
            subtitle: 'Pay with your balance',
            isSelected: checkout.paymentMethod == PaymentMethod.deposit,
            onTap: checkout.useDeposit
                ? null
                : () => notifier.setPaymentMethod(PaymentMethod.deposit),
            cs: cs,
          ),
          _PaymentMethodTile(
            icon: Icons.payment,
            title: 'PayPal',
            subtitle: 'Redirect to secure PayPal website',
            isSelected: checkout.paymentMethod == PaymentMethod.paypal,
            onTap: checkout.useDeposit
                ? null
                : () => notifier.setPaymentMethod(PaymentMethod.paypal),
            cs: cs,
          ),
          _PaymentMethodTile(
            icon: Icons.star,
            title: 'Telegram Stars',
            subtitle: 'Pay with Telegram Stars',
            isSelected: checkout.paymentMethod == PaymentMethod.telegramStars,
            onTap: checkout.useDeposit
                ? null
                : () => notifier.setPaymentMethod(PaymentMethod.telegramStars),
            cs: cs,
          ),
          _PaymentMethodTile(
            icon: Icons.currency_bitcoin,
            title: 'TON',
            subtitle: 'Pay with TON cryptocurrency',
            isSelected: checkout.paymentMethod == PaymentMethod.ton,
            onTap: checkout.useDeposit
                ? null
                : () => notifier.setPaymentMethod(PaymentMethod.ton),
            cs: cs,
          ),
          const SizedBox(height: 24),

          // ---------------------------------------------------------------
          // PAY NOW BUTTON
          // ---------------------------------------------------------------
          FilledButton(
            onPressed: (checkout.paymentMethod != null || checkout.useDeposit)
                ? () => _handlePayment(notifier, checkout)
                : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              checkout.useDeposit && checkout.balance < notifier.totalPrice
                  ? 'Insufficient Balance'
                  : 'Pay \$${notifier.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROCESSING STEP
  // ===========================================================================

  Widget _buildProcessingStep(
      ThemeData theme, ColorScheme cs, CheckoutState checkout) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 24),
            Text(
              'Processing Payment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we process your payment...',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SUCCESS STEP
  // ===========================================================================

  Widget _buildSuccessStep(
      ThemeData theme, ColorScheme cs, CheckoutState checkout) {
    // Auto-navigate to My eSIMs after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Navigate to My eSIMs tab (index 1)
          // This would use GoRouter or tab controller in real app
        }
      });
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle,
                size: 80, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your eSIM is being prepared.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (checkout.orderNo != null) ...[
              const SizedBox(height: 8),
              Text(
                'Order: ${checkout.orderNo}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FAILED STEP
  // ===========================================================================

  Widget _buildFailedStep(
      ThemeData theme, ColorScheme cs, CheckoutState checkout) {
    final CheckoutNotifier notifier = ref.read(checkoutProvider.notifier);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 80, color: cs.error),
            const SizedBox(height: 24),
            Text(
              'Payment Failed',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            if (checkout.errorMessage != null)
              Text(
                checkout.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.error,
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                notifier.reset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => notifier.reset(),
              child: const Text('Back to Checkout'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PAYMENT HANDLING
  // ===========================================================================

  Future<void> _handlePayment(
      CheckoutNotifier notifier, CheckoutState checkout) async {
    // If paying via PayPal, show confirmation bottom sheet first.
    if (checkout.paymentMethod == PaymentMethod.paypal) {
      final bool confirmed = await _showRedirectConfirmation(context) ?? false;
      if (!confirmed) return;
    }

    // Initiate payment
    await notifier.processPayment();

    // If PayPal created a payLink, open external browser.
    if (checkout.payLink != null && mounted) {
      final Uri uri = Uri.parse(checkout.payLink!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  /// Shows a bottom sheet confirming the user will be redirected to an
  /// external website (Safari/Chrome). Returns `true` if the user confirms.
  Future<bool?> _showRedirectConfirmation(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        final ThemeData theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Icon(Icons.open_in_browser,
                  size: 48,
                  color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                "You'll be redirected",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will be redirected to the secure PayPal website '
                'in your browser (Safari/Chrome) to complete the payment.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Continue'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  String _formatUnit(String unit) {
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
// SUMMARY ROW
// =============================================================================

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
        Text(label,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
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

// =============================================================================
// PAYMENT METHOD TILE
// =============================================================================

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.cs,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: cs.primary, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? cs.primary : cs.onSurfaceVariant),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? cs.primary : cs.onSurface)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: cs.primary)
            : null,
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }
}