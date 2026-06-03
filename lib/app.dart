import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/app_config.dart';
import 'screens/account_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_esims_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/settings/language_screen.dart';
import 'screens/settings/notifications_screen.dart';
import 'screens/settings/theme_screen.dart';

/// The root widget of the eSIM Marketplace application.
///
/// This widget sets up:
/// - EasyLocalization for i18n
/// - GoRouter for declarative navigation
/// - Material 3 theme with light/dark support
/// - BottomNavigationBar with 4 primary tabs
class ESIMApp extends ConsumerWidget {
  const ESIMApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Set system UI overlay style based on brightness
    final Brightness brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            brightness == Brightness.dark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );

    final GoRouter router = _buildRouter();

    return MaterialApp.router(
      // -----------------------------------------------------------------------
      // LOCALIZATION
      // -----------------------------------------------------------------------
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // -----------------------------------------------------------------------
      // ROUTER
      // -----------------------------------------------------------------------
      routerConfig: router,

      // -----------------------------------------------------------------------
      // THEME
      // -----------------------------------------------------------------------
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system, // Can be overridden via ThemeScreen

      // -----------------------------------------------------------------------
      // BUILDER (for Riverpod-scoped navigation)
      // -----------------------------------------------------------------------
      builder: (BuildContext context, Widget? child) {
        // Ensure text, button, etc. scale with the system accessibility
        // settings, but cap the upper bound to avoid broken layouts.
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.4,
                ),
          ),
          child: child!,
        );
      },
    );
  }

  // ===========================================================================
  // THEME DEFINITIONS
  // ===========================================================================

  /// Light theme based on Material 3 (Material You).
  ThemeData _buildLightTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D9488), // Teal-600 — primary brand
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withAlpha(128)),
        ),
        color: colorScheme.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surface,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(26),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: colorScheme.onSecondaryContainer,
                size: 24,
              );
            }
            return IconThemeData(
              color: colorScheme.onSurfaceVariant,
              size: 24,
            );
          },
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(128),
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.outline;
          },
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Dark theme based on Material 3 (Material You).
  ThemeData _buildDarkTheme() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF14B8A6), // Teal-500
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant.withAlpha(64)),
        ),
        color: colorScheme.surfaceContainerLow,
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surface,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(64),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              );
            }
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(
                color: colorScheme.onSecondaryContainer,
                size: 24,
              );
            }
            return IconThemeData(
              color: colorScheme.onSurfaceVariant,
              size: 24,
            );
          },
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(64),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withAlpha(64),
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.outline;
          },
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ===========================================================================
  // ROUTER (GoRouter)
  // ===========================================================================

  /// Builds the GoRouter instance with all routes defined declaratively.
  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: <RouteBase>[
        // -----------------------------------------------------------------------
        // SHELL ROUTE – Persistent BottomNavigationBar
        // -----------------------------------------------------------------------
        StatefulShellRoute.indexedStack(
          builder: (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) {
            return _MainShell(navigationShell: navigationShell);
          },
          branches: <StatefulShellBranch>[
            // -- Tab 0: Internet (Home) ---------------------------------------
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) =>
                      const HomeScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'checkout',
                      name: 'checkout',
                      builder: (BuildContext context, GoRouterState state) =>
                          const CheckoutScreen(),
                    ),
                  ],
                ),
              ],
            ),
            // -- Tab 1: My eSIMs ----------------------------------------------
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/my-esims',
                  builder: (BuildContext context, GoRouterState state) =>
                      const MyESIMsScreen(),
                ),
              ],
            ),
            // -- Tab 2: Orders ------------------------------------------------
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/orders',
                  builder: (BuildContext context, GoRouterState state) =>
                      const OrdersScreen(),
                ),
              ],
            ),
            // -- Tab 3: Account -----------------------------------------------
            StatefulShellBranch(
              routes: <RouteBase>[
                GoRoute(
                  path: '/account',
                  builder: (BuildContext context, GoRouterState state) =>
                      const AccountScreen(),
                  routes: <RouteBase>[
                    GoRoute(
                      path: 'language',
                      builder: (BuildContext context, GoRouterState state) =>
                          const LanguageScreen(),
                    ),
                    GoRoute(
                      path: 'theme',
                      builder: (BuildContext context, GoRouterState state) =>
                          const ThemeScreen(),
                    ),
                    GoRoute(
                      path: 'notifications',
                      builder: (BuildContext context, GoRouterState state) =>
                          const NotificationsScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// MAIN SHELL – BottomNavigationBar wrapper
// =============================================================================

/// The scaffold that holds the [BottomNavigationBar] and swaps between the
/// four primary tab views using a [StatefulNavigationShell].
class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(index);
        },
        animationDuration: const Duration(milliseconds: 300),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.language_rounded),
            selectedIcon: Icon(Icons.language_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer),
            label: 'home.internet'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.sim_card_rounded),
            selectedIcon: Icon(Icons.sim_card_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer),
            label: 'home.myEsims'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_rounded),
            selectedIcon: Icon(Icons.receipt_long_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer),
            label: 'home.orders'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            selectedIcon: Icon(Icons.person_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSecondaryContainer),
            label: 'home.account'.tr(),
          ),
        ],
      ),
    );
  }
}