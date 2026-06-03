import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';
import '../models/package.dart';
import '../providers/package_provider.dart';
import '../widgets/checkout_bottom_sheet.dart';
import '../widgets/loading_shimmer.dart';

// =============================================================================
// HOME SCREEN — Mirrors TypeScript `InternetTab.tsx`
// =============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _activeTab = 'countries'; // countries | regions | global
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Location? _selectedCountry;
  String? _selectedRegion;
  String? _expandedRegion;
  String _planType = 'standard'; // standard | unlimited
  Package? _selectedPlan;
  int _quantity = 1;
  String? _clickedPlanId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // MAIN BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    // Country-plans view
    if (_selectedCountry != null) {
      return _buildCountryPlansView(theme);
    }

    // Region-plans view
    if (_selectedRegion != null) {
      return _buildRegionPlansView(theme);
    }

    // Main catalog
    final locationsAsync = ref.watch(locationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Internet')),
      body: locationsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => _buildErrorView(theme, e.toString()),
        data: (List<Location> locations) => _buildCatalogView(theme, locations),
      ),
    );
  }

  // ===========================================================================
  // CATALOG VIEW (countries / regions / global)
  // ===========================================================================

  Widget _buildCatalogView(ThemeData theme, List<Location> locations) {
    final ColorScheme cs = theme.colorScheme;

    // Separate countries (type 1) and regions (type 2)
    final List<Location> countries =
        locations.where((l) => l.subLocationList == null || l.subLocationList!.isEmpty).toList();
    final List<Location> regions =
        locations.where((l) => l.subLocationList != null && l.subLocationList!.isNotEmpty).toList();

    // Filter
    final filtered = _activeTab == 'countries'
        ? countries.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList()
        : _activeTab == 'regions'
            ? regions.where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList()
            : regions; // global = all regions

    return RefreshIndicator(
      onRefresh: () => ref.refresh(locationsProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // SEARCH
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: const InputDecoration(
              hintText: 'Search countries...',
              prefixIcon: Icon(Icons.search, size: 22),
            ),
          ),
          const SizedBox(height: 16),

          // TAB BAR
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withAlpha(100),
              borderRadius: BorderRadius.circular(50),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: ['countries', 'regions', 'global'].map((tab) {
                final isSelected = _activeTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? cs.surface : Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: isSelected
                            ? [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Text(
                        tab == 'countries' ? 'Countries' : tab == 'regions' ? 'Regions' : 'Global',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // SECTION TITLE
          Text(
            _activeTab == 'countries'
                ? 'Popular Countries'
                : _activeTab == 'regions'
                    ? 'Available Regions'
                    : 'Global',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // COUNTRY LIST
          ..._buildCountryList(theme, cs, filtered),
        ],
      ),
    );
  }

  // ===========================================================================
  // COUNTRY LIST
  // ===========================================================================

  List<Widget> _buildCountryList(ThemeData theme, ColorScheme cs, List<Location> items) {
    if (items.isEmpty) {
      return [
        SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔍', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No results for "$_searchQuery"'
                      : 'No locations available',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final List<Widget> widgets = [];

    for (final Location item in items) {
      widgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: InkWell(
            onTap: () {
              if (_activeTab == 'countries') {
                setState(() => _selectedCountry = item);
              } else if ((_activeTab == 'regions' || _activeTab == 'global') &&
                  item.subLocationList != null &&
                  item.subLocationList!.isNotEmpty) {
                // Toggle expansion
                setState(() {
                  _expandedRegion = _expandedRegion == item.code ? null : item.code;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Flag
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 32,
                      height: 24,
                      child: CachedNetworkImage(
                        imageUrl: item.flag,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Center(child: Text('🌍', style: TextStyle(fontSize: 16))),
                        placeholder: (_, __) => Container(color: cs.surfaceContainerHighest),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Name + plans text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          item.packageCount != null && item.packageCount! > 0
                              ? '${item.packageCount} plans from \$${(item.cheapestPrice ?? 0).toStringAsFixed(2)}'
                              : 'No plans available',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Chevron (or expand icon for regions)
                  Icon(
                    item.subLocationList != null && item.subLocationList!.isNotEmpty
                        ? (_expandedRegion == item.code
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down)
                        : Icons.chevron_right,
                    size: 20,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Sub-locations (if expanded)
      if ((_activeTab == 'regions' || _activeTab == 'global') &&
          _expandedRegion == item.code &&
          item.subLocationList != null) {
        for (final SubLocation sub in item.subLocationList!) {
          if (_searchQuery.isNotEmpty &&
              !sub.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
            continue;
          }
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Card(
                child: InkWell(
                  onTap: () {
                    final Location subCountry = Location(
                      name: sub.name,
                      code: sub.code,
                      flag: 'https://flagsapi.com/${sub.code}/flat/64.png',
                      color: item.color,
                    );
                    setState(() {
                      _selectedCountry = subCountry;
                      _expandedRegion = null;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: SizedBox(
                            width: 24,
                            height: 18,
                            child: CachedNetworkImage(
                              imageUrl: 'https://flagsapi.com/${sub.code}/flat/64.png',
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Center(child: Text('🌍', style: TextStyle(fontSize: 12))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(sub.name, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface)),
                        const Spacer(),
                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  // ===========================================================================
  // COUNTRY PLANS VIEW
  // ===========================================================================

  Widget _buildCountryPlansView(ThemeData theme) {
    final country = _selectedCountry!;
    final ColorScheme cs = theme.colorScheme;
    final packagesAsync = ref.watch(packagesProvider(country.code));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _selectedCountry = null;
            _selectedPlan = null;
          }),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                width: 32,
                height: 24,
                child: CachedNetworkImage(
                  imageUrl: country.flag,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Center(child: Text('🌍', style: TextStyle(fontSize: 16))),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(country.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
      body: packagesAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => _buildErrorView(theme, e.toString()),
        data: (List<Package> packages) => _buildPackageList(theme, cs, country, packages),
      ),
    );
  }

  // ===========================================================================
  // REGION PLANS VIEW (uses /api/region-packages)
  // ===========================================================================

  Widget _buildRegionPlansView(ThemeData theme) {
    final String region = _selectedRegion!;
    final ColorScheme cs = theme.colorScheme;
    final regionAsync = ref.watch(regionPackagesProvider(region));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() {
            _selectedRegion = null;
            _selectedPlan = null;
          }),
        ),
        title: Text(region, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: regionAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => _buildErrorView(theme, e.toString()),
        data: (RegionPackagesData regionData) {
          return Column(
            children: [
              // Package list
              Expanded(
                child: _buildPackageList(theme, cs, null, regionData.packages),
              ),

              // Supported countries
              if (regionData.supportedCountries.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant.withAlpha(100)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available in',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${regionData.supportedCountries.join(', ')}.',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // PACKAGE LIST
  // ===========================================================================

  Widget _buildPackageList(ThemeData theme, ColorScheme cs, Location? country, List<Package> packages) {
    if (packages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_off, size: 48, color: cs.onSurfaceVariant.withAlpha(100)),
            const SizedBox(height: 12),
            Text('No plans available', style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Sort by data amount
    final sorted = [...packages]
      ..sort((a, b) => (int.tryParse(a.data) ?? 0).compareTo(int.tryParse(b.data) ?? 0));

    final standardPlans = sorted.where((p) => !p.isUnlimited).toList();
    final unlimitedPlans = sorted.where((p) => p.isUnlimited).toList();

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            // Description
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Choose a data plan', style: TextStyle(color: cs.onSurfaceVariant)),
            ),

            // Standard / Unlimited tabs
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withAlpha(100),
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: ['standard', 'unlimited'].map((type) {
                  final isSelected = _planType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _planType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? cs.surface : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)]
                              : null,
                        ),
                        child: Text(
                          type == 'standard' ? 'Standard' : 'Unlimited',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Package cards
            ...(_planType == 'standard' ? standardPlans : unlimitedPlans).map((plan) {
              final bool isSelected = _selectedPlan?.id == plan.id;
              final bool isClicked = _clickedPlanId == plan.id;

              return AnimatedScale(
                scale: isClicked ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isSelected
                        ? BorderSide(color: cs.primary, width: 2)
                        : BorderSide(color: cs.outlineVariant.withAlpha(64)),
                  ),
                  color: isSelected ? cs.primaryContainer.withAlpha(50) : cs.surface,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _clickedPlanId = plan.id;
                        _selectedPlan = null;
                      });
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (mounted) {
                          setState(() {
                            _selectedPlan = plan;
                            _clickedPlanId = null;
                          });
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          // LEFT: data + validity
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badges
                                if (plan.supports5G || plan.isUnlimited || plan.isBestSeller)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (plan.supports5G) _badge('5G', cs.secondaryContainer, cs.onSecondaryContainer),
                                      if (plan.isUnlimited) _badge('UNLIMITED', cs.primaryContainer, cs.onPrimaryContainer),
                                      if (plan.isBestSeller) _badge('⭐ BEST SELLER', Colors.orange.shade100, Colors.orange.shade900),
                                    ],
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  plan.isUnlimited ? 'Unlimited' : '${plan.data} ${plan.dataUnit}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface,
                                  ),
                                ),
                                Text(
                                  '${plan.duration} ${_formatDuration(plan.durationUnit)}',
                                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),

                          // RIGHT: price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${plan.price.toStringAsFixed(2)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              FilledButton(
                                onPressed: () => _showCheckoutSheet(plan),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                child: const Text('Get Plan'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),

        // Floating Purchase button
        if (_selectedPlan != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select number of eSIM', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 22),
                                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                              ),
                              Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, size: 22),
                                onPressed: () => setState(() => _quantity++),
                              ),
                              if (_quantity > 1)
                                Text(' Total: \$${(_selectedPlan!.price * _quantity).toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: _selectedPlan != null ? () => _showCheckoutSheet(_selectedPlan!) : null,
                      child: Text('Purchase'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ===========================================================================
  // ERROR VIEW
  // ===========================================================================

  Widget _buildErrorView(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => ref.invalidate(locationsProvider),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CHECKOUT BOTTOM SHEET
  // ===========================================================================

  void _showCheckoutSheet(Package package) {
    final Location? loc = _selectedCountry ?? (_selectedRegion != null
        ? Location(name: _selectedRegion!, code: _selectedRegion!, flag: '🌍', color: '#6366F1')
        : null);

    if (loc == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CheckoutBottomSheet(country: loc, package: package),
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  Widget _badge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg, letterSpacing: 0.5)),
    );
  }

  String _formatDuration(String unit) {
    switch (unit.toUpperCase()) {
      case 'DAY': return 'Days';
      case 'WEEK': return 'Weeks';
      case 'MONTH': return 'Months';
      default: return unit;
    }
  }
}