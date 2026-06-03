import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/esim.dart';

/// A full-screen modal that displays the eSIM QR code for installation.
///
/// Features:
/// - Title bar with eSIM country + flag
/// - Large QR code rendered by [qr_flutter]
/// - ICCID display with copy-to-clipboard button
/// - "How to Install" section with numbered steps
/// - Close button at the top
class QRModal extends StatelessWidget {
  const QRModal({
    super.key,
    required this.esim,
  });

  final ESIM esim;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${esim.flag} ${esim.country}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // PLAN INFO
            // ---------------------------------------------------------------
            Text(
              esim.plan,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // ---------------------------------------------------------------
            // QR CODE
            // ---------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant.withAlpha(128)),
              ),
              child: QrImageView(
                data: esim.shortUrl,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0D9488),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0D9488),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------------------------------------------------------------
            // ICCID WITH COPY BUTTON
            // ---------------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ICCID',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          esim.iccid,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: esim.iccid));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('ICCID copied to clipboard'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy ICCID',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ---------------------------------------------------------------
            // HOW TO INSTALL
            // ---------------------------------------------------------------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How to Install',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            _InstallStep(
              number: '1',
              title: 'Scan the QR Code',
              description: 'Open your phone\'s camera app and point it at the QR code above.',
              cs: cs,
            ),
            _InstallStep(
              number: '2',
              title: 'Tap the Notification',
              description: 'When the eSIM notification appears, tap it to begin installation.',
              cs: cs,
            ),
            _InstallStep(
              number: '3',
              title: 'Follow On-Screen Instructions',
              description: 'Your device will guide you through the remaining setup steps.',
              cs: cs,
            ),
            _InstallStep(
              number: '4',
              title: 'Activate Data Roaming',
              description: 'Once installed, go to Settings → Cellular and enable Data Roaming for this eSIM.',
              cs: cs,
            ),
            const SizedBox(height: 24),

            // ---------------------------------------------------------------
            // ORDER NUMBER
            // ---------------------------------------------------------------
            Text(
              'Order: ${esim.orderNo}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// INSTALL STEP WIDGET
// =============================================================================

class _InstallStep extends StatelessWidget {
  const _InstallStep({
    required this.number,
    required this.title,
    required this.description,
    required this.cs,
  });

  final String number;
  final String title;
  final String description;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}