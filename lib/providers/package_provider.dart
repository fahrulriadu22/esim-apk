import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/location.dart';
import '../models/package.dart';
import '../services/api_service.dart';
import '../utils/logger.dart';

// =============================================================================
// SELECTED COUNTRY PROVIDER
// =============================================================================
final selectedCountryProvider = StateProvider<Location?>((ref) => null);

// =============================================================================
// LOCATIONS PROVIDER (calls /api/locations)
// =============================================================================

final locationsProvider = FutureProvider<List<Location>>((ref) async {
  try {
    final http.Response response = await ApiService.get(
      ApiConfig.locationsEndpoint,
    );
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['success'] == true && data['data'] != null) {
      final List rawList = data['data'] as List;
      const List<String> colorPalette = [
        '#EF4444', '#3B82F6', '#10B981', '#F59E0B', '#8B5CF6',
        '#EC4899', '#6366F1', '#F97316', '#14B8A6', '#06B6D4',
        '#84CC16', '#F59E0B', '#10B981', '#8B5CF6', '#F43F5E', '#0EA5E9',
      ];

      return rawList.map((item) {
        final Map<String, dynamic> loc = item as Map<String, dynamic>;
        final int index = rawList.indexOf(item);
        final String code = loc['code']?.toString() ?? '';
        final int packageCount = loc['packageCount'] ?? 0;
        final double startingPrice = (loc['startingPrice'] ?? 0).toDouble();
        final List? subLocationsRaw = loc['subLocationList'];

        return Location(
          name: loc['name']?.toString() ?? '',
          color: colorPalette[index % colorPalette.length],
          code: code,
          flag: 'https://flagsapi.com/$code/flat/64.png',
          cheapestPrice: startingPrice,
          packageCount: packageCount,
          subLocationList: subLocationsRaw?.map((sub) {
            final s = sub as Map<String, dynamic>;
            return SubLocation(code: s['code']?.toString() ?? '', name: s['name']?.toString() ?? '');
          }).toList(),
        );
      }).toList();
    }

    throw Exception(data['error'] ?? 'Failed to fetch locations');
  } catch (e, stack) {
    AppLogger.warn('Locations API failed, using fallback', e, stack);
    return _fallbackLocations();
  }
});

// =============================================================================
// PACKAGES PROVIDER (calls /api/package?locationCode=XX)
// =============================================================================

final packagesProvider = FutureProvider.autoDispose
    .family<List<Package>, String?>((ref, countryCode) async {
  if (countryCode == null) return [];

  try {
    final http.Response response = await ApiService.get(
      ApiConfig.packagesEndpoint,
      queryParams: {'locationCode': countryCode},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['success'] == true && data['data'] != null) {
      final List rawList = data['data'] as List;
      return rawList.map((item) {
        final Map<String, dynamic> pkg = item as Map<String, dynamic>;
        return Package(
          id: pkg['id']?.toString() ?? '',
          name: pkg['name']?.toString() ?? '',
          code: pkg['code']?.toString() ?? '',
          duration: pkg['duration'] ?? 0,
          durationUnit: pkg['durationUnit']?.toString() ?? 'DAY',
          price: (pkg['price'] ?? 0).toDouble(),
          data: pkg['data']?.toString() ?? '0',
          dataUnit: pkg['dataUnit']?.toString() ?? 'GB',
          pricePerData: (pkg['pricePerData'] ?? 0).toDouble(),
          regionId: pkg['regionId']?.toString() ?? '',
          supports5G: pkg['supports5G'] == true,
          isUnlimited: (pkg['data']?.toString() ?? '') == 'Unlimited',
          isBestSeller: pkg['isBestSeller'] == true,
        );
      }).toList();
    }

    throw Exception(data['error'] ?? 'Failed to fetch packages');
  } catch (e, stack) {
    AppLogger.warn('Packages API failed for $countryCode, using fallback', e, stack);
    return _fallbackPackages(countryCode);
  }
});

// =============================================================================
// REGION PACKAGES PROVIDER (calls /api/region-packages?regionName=XX)
// =============================================================================

final regionPackagesProvider = FutureProvider.autoDispose
    .family<RegionPackagesData, String?>((ref, regionName) async {
  if (regionName == null) {
    return const RegionPackagesData(packages: [], supportedCountries: []);
  }

  try {
    final http.Response response = await ApiService.get(
      ApiConfig.regionPackagesEndpoint,
      queryParams: {'regionName': regionName},
    );
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['success'] == true && data['data'] != null) {
      final Map<String, dynamic> result = data['data'] as Map<String, dynamic>;
      final List rawPackages = result['packages'] ?? [];
      final List rawCountries = result['supportedCountries'] ?? [];

      final List<Package> packages = rawPackages.map((item) {
        final Map<String, dynamic> pkg = item as Map<String, dynamic>;
        return Package(
          id: pkg['id']?.toString() ?? '',
          name: pkg['name']?.toString() ?? '',
          code: pkg['code']?.toString() ?? '',
          duration: pkg['duration'] ?? 0,
          durationUnit: pkg['durationUnit']?.toString() ?? 'DAY',
          price: (pkg['price'] ?? 0).toDouble(),
          data: pkg['data']?.toString() ?? '0',
          dataUnit: pkg['dataUnit']?.toString() ?? 'GB',
          pricePerData: (pkg['pricePerData'] ?? 0).toDouble(),
          regionId: regionName,
          supports5G: true,
          isUnlimited: (pkg['data']?.toString() ?? '') == 'Unlimited',
          isBestSeller: false,
        );
      }).toList();

      return RegionPackagesData(
        packages: packages,
        supportedCountries: rawCountries.map((c) => c.toString()).toList(),
      );
    }

    throw Exception(data['error'] ?? 'Failed to fetch region packages');
  } catch (e, stack) {
    AppLogger.warn('Region packages API failed for $regionName, using fallback', e, stack);
    return RegionPackagesData(
      packages: _fallbackPackages(regionName),
      supportedCountries: _fallbackRegionCountries(regionName),
    );
  }
});

class RegionPackagesData {
  final List<Package> packages;
  final List<String> supportedCountries;
  const RegionPackagesData({required this.packages, required this.supportedCountries});
}

// =============================================================================
// ALL PRICES PROVIDER (calls /api/all-packages)
// =============================================================================

final allPricesProvider = FutureProvider<Map<String, PriceInfo>>((ref) async {
  try {
    final http.Response response = await ApiService.get(
      ApiConfig.allPackagesEndpoint,
    );
    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['success'] == true && data['data'] != null) {
      final Map<String, dynamic> raw = data['data'] as Map<String, dynamic>;
      final Map<String, PriceInfo> result = {};
      raw.forEach((code, value) {
        final v = value as Map<String, dynamic>;
        result[code] = PriceInfo(
          cheapest: (v['cheapest'] ?? 0).toDouble(),
          count: v['count'] ?? 0,
        );
      });
      return result;
    }

    throw Exception(data['error'] ?? 'Failed to fetch prices');
  } catch (e, stack) {
    AppLogger.warn('All-packages API failed', e, stack);
    return {};
  }
});

class PriceInfo {
  final double cheapest;
  final int count;
  const PriceInfo({required this.cheapest, required this.count});
}

// =============================================================================
// FALLBACK DATA
// =============================================================================

List<Location> _fallbackLocations() {
  return [
    Location(name: 'Indonesia', color: '#EF4444', code: 'ID', flag: 'https://flagsapi.com/ID/flat/64.png', cheapestPrice: 3.50, packageCount: 12),
    Location(name: 'Japan', color: '#EAB308', code: 'JP', flag: 'https://flagsapi.com/JP/flat/64.png', cheapestPrice: 4.99, packageCount: 8),
    Location(name: 'South Korea', color: '#3B82F6', code: 'KR', flag: 'https://flagsapi.com/KR/flat/64.png', cheapestPrice: 3.00, packageCount: 6),
    Location(name: 'Turkey', color: '#DC2626', code: 'TR', flag: 'https://flagsapi.com/TR/flat/64.png', cheapestPrice: 5.50, packageCount: 10),
    Location(name: 'United States', color: '#2563EB', code: 'US', flag: 'https://flagsapi.com/US/flat/64.png', cheapestPrice: 4.00, packageCount: 15),
    Location(name: 'United Kingdom', color: '#1E40AF', code: 'GB', flag: 'https://flagsapi.com/GB/flat/64.png', cheapestPrice: 3.99, packageCount: 9),
    Location(name: 'France', color: '#3B82F6', code: 'FR', flag: 'https://flagsapi.com/FR/flat/64.png', cheapestPrice: 4.50, packageCount: 7),
    Location(name: 'Germany', color: '#F59E0B', code: 'DE', flag: 'https://flagsapi.com/DE/flat/64.png', cheapestPrice: 4.25, packageCount: 11),
    Location(name: 'Thailand', color: '#10B981', code: 'TH', flag: 'https://flagsapi.com/TH/flat/64.png', cheapestPrice: 2.99, packageCount: 5),
    Location(name: 'Singapore', color: '#EF4444', code: 'SG', flag: 'https://flagsapi.com/SG/flat/64.png', cheapestPrice: 5.00, packageCount: 4),
    Location(name: 'Australia', color: '#F59E0B', code: 'AU', flag: 'https://flagsapi.com/AU/flat/64.png', cheapestPrice: 6.00, packageCount: 8),
    Location(name: 'United Arab Emirates', color: '#10B981', code: 'AE', flag: 'https://flagsapi.com/AE/flat/64.png', cheapestPrice: 7.50, packageCount: 6),
  ];
}

List<Package> _fallbackPackages(String countryCode) {
  final int seed = countryCode.hashCode.abs();
  return [
    Package(id: '${countryCode}_1', name: '1 GB Plan', code: 'PKG_1GB_7D', duration: 7, durationUnit: 'DAY', price: 2.99 + ((seed % 10) / 10), data: '1', dataUnit: 'GB', pricePerData: 2.99, regionId: countryCode, supports5G: seed % 3 == 0, isBestSeller: false),
    Package(id: '${countryCode}_2', name: '3 GB Plan', code: 'PKG_3GB_7D', duration: 7, durationUnit: 'DAY', price: 4.99 + ((seed % 10) / 10), data: '3', dataUnit: 'GB', pricePerData: 1.66, regionId: countryCode, supports5G: seed % 2 == 0, isBestSeller: true),
    Package(id: '${countryCode}_3', name: '5 GB Plan', code: 'PKG_5GB_15D', duration: 15, durationUnit: 'DAY', price: 7.99 + ((seed % 10) / 10), data: '5', dataUnit: 'GB', pricePerData: 1.60, regionId: countryCode, supports5G: true, isBestSeller: false),
    Package(id: '${countryCode}_4', name: 'Unlimited Data', code: 'PKG_UNL_30D', duration: 30, durationUnit: 'DAY', price: 24.99 + ((seed % 10) / 10), data: 'Unlimited', dataUnit: '', pricePerData: 0, regionId: countryCode, supports5G: true, isUnlimited: true, isBestSeller: false),
  ];
}

List<String> _fallbackRegionCountries(String regionName) {
  switch (regionName.toLowerCase()) {
    case 'europe':
      return ['France', 'Germany', 'Italy', 'Spain', 'United Kingdom', 'Netherlands', 'Poland', 'Portugal'];
    case 'asia':
      return ['Japan', 'South Korea', 'Thailand', 'Indonesia', 'Singapore', 'Malaysia', 'Vietnam', 'Philippines'];
    case 'north america':
      return ['United States', 'Canada', 'Mexico'];
    case 'south america':
      return ['Brazil', 'Argentina', 'Chile', 'Colombia', 'Peru'];
    case 'africa':
      return ['South Africa', 'Nigeria', 'Kenya', 'Egypt', 'Morocco'];
    case 'middle east & north africa':
      return ['United Arab Emirates', 'Saudi Arabia', 'Qatar', 'Kuwait', 'Egypt', 'Morocco'];
    case 'central asia':
      return ['Kazakhstan', 'Uzbekistan', 'Turkmenistan', 'Kyrgyzstan', 'Tajikistan'];
    default:
      return ['Various Countries'];
  }
}