import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Allows the user to switch the application language between English,
/// Bahasa Indonesia, and Russian.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final List<LanguageOption> options = [
      const LanguageOption(
        locale: Locale('en', 'US'),
        label: 'English',
        nativeLabel: 'English',
        flag: '🇺🇸',
      ),
      const LanguageOption(
        locale: Locale('id', 'ID'),
        label: 'Bahasa Indonesia',
        nativeLabel: 'Bahasa Indonesia',
        flag: '🇮🇩',
      ),
      const LanguageOption(
        locale: Locale('ru', 'RU'),
        label: 'Russian',
        nativeLabel: 'Русский',
        flag: '🇷🇺',
      ),
    ];

    final Locale currentLocale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Language',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (BuildContext context, int index) {
          final LanguageOption option = options[index];
          final bool isSelected =
              currentLocale.languageCode == option.locale.languageCode;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(color: cs.primary, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Text(option.flag, style: const TextStyle(fontSize: 28)),
              title: Text(
                option.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                option.nativeLabel,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: cs.primary)
                  : null,
              onTap: isSelected
                  ? null
                  : () async {
                      await context.setLocale(option.locale);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Language changed to ${option.label}',
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            ),
          );
        },
      ),
    );
  }
}

class LanguageOption {
  final Locale locale;
  final String label;
  final String nativeLabel;
  final String flag;

  const LanguageOption({
    required this.locale,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });
}