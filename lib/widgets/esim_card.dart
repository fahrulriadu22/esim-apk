import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/esim.dart';

/// Displays a single eSIM card with status badge, data usage progress
/// bar, expiry countdown, and action buttons (View QR, Copy ICCID).
class ESIMCard extends StatelessWidget {
  const ESIMCard({
    super.key,
    required this.esim,
    required this.onViewQr,
  });

  final ESIM esim;
  final VoidCallback onViewQr;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------------------------------------------------------
            // TOP ROW – Flag, Country, Status badge
            // ---------------------------------------------------------------
            Row(
              children: [
                Text(esim.flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esim.country,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        esim.plan,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: esim.status),
              ],
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // DATA USAGE PROGRESS BAR
            // ---------------------------------------------------------------
            Row(
              children: [
                Text(
                  '${esim.dataUsed.toStringAsFixed(1)} / ${esim.dataTotal.toStringAsFixed(1)} ${esim.remainingDataUnit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(esim.dataUsagePercent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _progressColor(esim.status, cs),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: esim.dataUsagePercent,
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progressColor(esim.status, cs),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // EXPIRY COUNTDOWN
            // ---------------------------------------------------------------
            _ExpiryRow(esim: esim, cs: cs),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // ACTION BUTTONS
            // ---------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewQr,
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: const Text('View QR'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyIccid(context, esim.iccid),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy ICCID'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Copies the ICCID to clipboard and shows a snackbar.
  void _copyIccid(BuildContext context, String iccid) {
    Clipboard.setData(ClipboardData(text: iccid));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ICCID copied: $iccid'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Returns a color based on eSIM status.
  Color _progressColor(ESIMStatus status, ColorScheme cs) {
    switch (status) {
      case ESIMStatus.active:
        return Colors.green;
      case ESIMStatus.lowData:
        return Colors.orange;
      case ESIMStatus.expired:
        return cs.error;
      case ESIMStatus.new_:
        return cs.primary;
    }
  }
}

// =============================================================================
// STATUS BADGE
// =============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ESIMStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = _statusConfig;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  (String, Color, Color) get _statusConfig {
    switch (status) {
      case ESIMStatus.new_:
        return ('NEW', Colors.blue.shade100, Colors.blue.shade800);
      case ESIMStatus.active:
        return ('ACTIVE', Colors.green.shade100, Colors.green.shade800);
      case ESIMStatus.lowData:
        return ('LOW DATA', Colors.orange.shade100, Colors.orange.shade900);
      case ESIMStatus.expired:
        return ('EXPIRED', Colors.red.shade100, Colors.red.shade800);
    }
  }
}

// =============================================================================
// EXPIRY ROW
// =============================================================================

class _ExpiryRow extends StatelessWidget {
  const _ExpiryRow({required this.esim, required this.cs});

  final ESIM esim;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          esim.daysLeft > 0 ? '${esim.daysLeft} days left' : 'Expired',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '· Expires ${_formatDate(esim.expiredAt)}',
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}