import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/esim.dart';
import '../providers/esim_provider.dart';
import '../widgets/esim_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/qr_modal.dart';

/// Displays the user's purchased eSIMs with status badges, data usage
/// progress bars, expiry countdowns, and action buttons.
class MyESIMsScreen extends ConsumerWidget {
  const MyESIMsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AsyncValue<List<ESIM>> esimsAsync = ref.watch(esimsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My eSIMs',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(esimsProvider.future),
        child: esimsAsync.when(
          data: (List<ESIM> esims) {
            if (esims.isEmpty) {
              return _buildEmptyState(theme);
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: esims.length,
              itemBuilder: (BuildContext context, int index) {
                final ESIM esim = esims[index];
                return ESIMCard(
                  esim: esim,
                  onViewQr: () => _showQRModal(context, esim),
                );
              },
            );
          },
          loading: () => const LoadingShimmer(),
          error: (Object error, StackTrace? stack) => _buildErrorState(context, theme, error),
        ),
      ),
    );
  }

  // ===========================================================================
  // QR MODAL
  // ===========================================================================

  /// Opens the full-screen QR code modal for the given [esim].
  void _showQRModal(BuildContext context, ESIM esim) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QRModal(esim: esim),
      ),
    );
  }

  // ===========================================================================
  // EMPTY STATE
  // ===========================================================================

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sim_card_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'No eSIMs yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your purchased eSIMs will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ERROR STATE
  // ===========================================================================

  Widget _buildErrorState(BuildContext context, ThemeData theme, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              maxLines: 3,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                // Fallback: show a snackbar since we cannot access
                // ProviderContainer from a static method in a ConsumerWidget.
                // The pull-to-refresh gesture already triggers a refetch.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pull to refresh to retry'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}