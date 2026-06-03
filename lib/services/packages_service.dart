import '../models/location.dart';
import '../models/package.dart';

/// Service for fetching package and location data.
///
/// Currently returns hard-coded dummy data. In production this should
/// call the backend API via [ApiService].
class PackageService {
  // ---------------------------------------------------------------------------
  // LOCATIONS
  // ---------------------------------------------------------------------------

  /// Fetches all supported countries.
  static Future<List<Location>> fetchLocations() async {
    // TODO: Replace with real API call
    // final response = await ApiService.get(ApiConfig.locationsEndpoint);
    // final data = jsonDecode(response.body);
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      Location(name: 'Indonesia', color: '#EF4444', code: 'ID', flag: '🇮🇩', cheapestPrice: 3.50, packageCount: 12),
      Location(name: 'Japan', color: '#EAB308', code: 'JP', flag: '🇯🇵', cheapestPrice: 4.99, packageCount: 8),
      Location(name: 'South Korea', color: '#3B82F6', code: 'KR', flag: '🇰🇷', cheapestPrice: 3.00, packageCount: 6),
      Location(name: 'Turkey', color: '#DC2626', code: 'TR', flag: '🇹🇷', cheapestPrice: 5.50, packageCount: 10),
      Location(name: 'United States', color: '#2563EB', code: 'US', flag: '🇺🇸', cheapestPrice: 4.00, packageCount: 15),
      Location(name: 'United Kingdom', color: '#1E40AF', code: 'GB', flag: '🇬🇧', cheapestPrice: 3.99, packageCount: 9),
      Location(name: 'France', color: '#3B82F6', code: 'FR', flag: '🇫🇷', cheapestPrice: 4.50, packageCount: 7),
      Location(name: 'Germany', color: '#F59E0B', code: 'DE', flag: '🇩🇪', cheapestPrice: 4.25, packageCount: 11),
      Location(name: 'Thailand', color: '#10B981', code: 'TH', flag: '🇹🇭', cheapestPrice: 2.99, packageCount: 5),
      Location(name: 'Singapore', color: '#EF4444', code: 'SG', flag: '🇸🇬', cheapestPrice: 5.00, packageCount: 4),
      Location(name: 'Australia', color: '#F59E0B', code: 'AU', flag: '🇦🇺', cheapestPrice: 6.00, packageCount: 8),
      Location(name: 'United Arab Emirates', color: '#10B981', code: 'AE', flag: '🇦🇪', cheapestPrice: 7.50, packageCount: 6),
    ];
  }

  // ---------------------------------------------------------------------------
  // PACKAGES
  // ---------------------------------------------------------------------------

  /// Fetches available data packages for a given [countryCode].
  static Future<List<Package>> fetchPackages(String countryCode) async {
    // TODO: Replace with real API call
    // final response = await ApiService.get(
    //   ApiConfig.packagesEndpoint,
    //   queryParams: {'locationCode': countryCode},
    // );
    // final data = jsonDecode(response.body);
    await Future.delayed(const Duration(milliseconds: 500));

    final int seed = countryCode.hashCode;

    return [
      Package(
        id: '${countryCode}_1',
        name: '1 GB Plan',
        code: 'PKG_1GB_7D',
        duration: 7,
        durationUnit: 'DAY',
        price: 2.99 + ((seed % 10) / 10),
        data: '1',
        dataUnit: 'GB',
        pricePerData: 2.99,
        regionId: countryCode,
        supports5G: seed % 3 == 0,
        isBestSeller: false,
      ),
      Package(
        id: '${countryCode}_2',
        name: '3 GB Plan',
        code: 'PKG_3GB_7D',
        duration: 7,
        durationUnit: 'DAY',
        price: 4.99 + ((seed % 10) / 10),
        data: '3',
        dataUnit: 'GB',
        pricePerData: 1.66,
        regionId: countryCode,
        supports5G: seed % 2 == 0,
        isBestSeller: true,
      ),
      Package(
        id: '${countryCode}_3',
        name: '5 GB Plan',
        code: 'PKG_5GB_15D',
        duration: 15,
        durationUnit: 'DAY',
        price: 7.99 + ((seed % 10) / 10),
        data: '5',
        dataUnit: 'GB',
        pricePerData: 1.60,
        regionId: countryCode,
        supports5G: true,
        isBestSeller: false,
      ),
      Package(
        id: '${countryCode}_4',
        name: 'Unlimited Data',
        code: 'PKG_UNL_30D',
        duration: 30,
        durationUnit: 'DAY',
        price: 24.99 + ((seed % 10) / 10),
        data: 'Unlimited',
        dataUnit: '',
        pricePerData: 0,
        regionId: countryCode,
        supports5G: true,
        isUnlimited: true,
        isBestSeller: false,
      ),
    ];
  }

  /// Fetches region packages (continent-level plans).
  static Future<List<Package>> fetchRegionPackages(String region) async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 500));
    return fetchPackages(region);
  }
}