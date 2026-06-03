import 'package:flutter/material.dart';

/// Allows the user to configure push- and email-notification preferences.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _promoEnabled = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------------------------------------------------------
          // SECTION HEADER
          // ---------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              'Push Notifications',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive order updates and reminders'),
                  value: _pushEnabled,
                  onChanged: (bool v) => setState(() => _pushEnabled = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.local_offer_outlined),
                  title: const Text('Promotional Notifications'),
                  subtitle: const Text('Special offers and new packages'),
                  value: _promoEnabled,
                  onChanged: _pushEnabled
                      ? (bool v) => setState(() => _promoEnabled = v)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---------------------------------------------------------------
          // EMAIL SECTION
          // ---------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              'Email Notifications',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.email_outlined),
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive order receipts via email'),
              value: _emailEnabled,
              onChanged: (bool v) => setState(() => _emailEnabled = v),
            ),
          ),
          const SizedBox(height: 32),

          // ---------------------------------------------------------------
          // SAVE BUTTON
          // ---------------------------------------------------------------
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification preferences saved'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    );
  }
}