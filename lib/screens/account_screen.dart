import 'package:flutter/material.dart';

import 'settings/language_screen.dart';
import 'settings/notifications_screen.dart';
import 'settings/theme_screen.dart';

/// Displays the user's profile, balance, and a list of account-related
/// settings (language, theme, notifications, legal pages).
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    // ---- MOCK USER DATA ----
    const String username = 'fahrul';
    const String fullName = 'Fahrul Rizal';
    const double balance = 75.50;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------------------------------------------------------
            // PROFILE HEADER
            // ---------------------------------------------------------------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        fullName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '@$username',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // BALANCE CARD
            // ---------------------------------------------------------------
            Card(
              color: cs.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined,
                        size: 28, color: cs.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balance',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.onPrimaryContainer.withAlpha(180))),
                        Text('\$${balance.toStringAsFixed(2)}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: cs.onPrimaryContainer)),
                      ],
                    ),
                    const Spacer(),
                    FilledButton.tonal(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Top Up feature coming soon'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Top Up'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // SETTINGS MENU
            // ---------------------------------------------------------------
            _MenuSection(
              title: 'Settings',
              items: [
                _MenuItem(
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: 'English',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LanguageScreen(),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  subtitle: 'System',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ThemeScreen(),
                    ),
                  ),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Enabled',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
              ],
              cs: cs,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // SUPPORT & LEGAL
            // ---------------------------------------------------------------
            _MenuSection(
              title: 'Support & Legal',
              items: [
                _MenuItem(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'FAQ',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.support_agent,
                  title: 'Contact Support',
                  onTap: () {},
                ),
              ],
              cs: cs,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // ---------------------------------------------------------------
            // APP INFO
            // ---------------------------------------------------------------
            Center(
              child: Text(
                'eSIM Marketplace v1.0.0',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MENU SECTION
// =============================================================================

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.items,
    required this.cs,
    required this.theme,
  });

  final String title;
  final List<_MenuItem> items;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.map((item) => _MenuItemTile(item: item, cs: cs)),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item, required this.cs});

  final _MenuItem item;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(item.icon, color: cs.onSurfaceVariant),
      title: Text(item.title,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: cs.onSurface)),
      subtitle: item.subtitle != null
          ? Text(item.subtitle!,
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant))
          : null,
      trailing: item.onTap != null
          ? Icon(Icons.chevron_right, color: cs.onSurfaceVariant)
          : null,
      onTap: item.onTap,
    );
  }
}

