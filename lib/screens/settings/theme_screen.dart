import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows the user to select between System, Light, and Dark theme modes.
class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  ThemeMode _currentMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('theme_mode');
    if (mounted) {
      setState(() {
        _currentMode = switch (saved) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        };
      });
    }
  }

  Future<void> _setTheme(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString('theme_mode', value);
    setState(() => _currentMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    final List<_ThemeOption> options = [
      _ThemeOption(
        mode: ThemeMode.system,
        label: 'System',
        icon: Icons.settings_suggest,
        description: 'Follow system settings',
      ),
      _ThemeOption(
        mode: ThemeMode.light,
        label: 'Light',
        icon: Icons.light_mode,
        description: 'Always use light appearance',
      ),
      _ThemeOption(
        mode: ThemeMode.dark,
        label: 'Dark',
        icon: Icons.dark_mode,
        description: 'Always use dark appearance',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theme',
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
          final _ThemeOption option = options[index];
          final bool isSelected = _currentMode == option.mode;

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? BorderSide(color: cs.primary, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Icon(option.icon,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant),
              title: Text(
                option.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              subtitle: Text(
                option.description,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: cs.primary)
                  : null,
              onTap: () => _setTheme(option.mode),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeOption {
  final ThemeMode mode;
  final String label;
  final IconData icon;
  final String description;

  const _ThemeOption({
    required this.mode,
    required this.label,
    required this.icon,
    required this.description,
  });
}