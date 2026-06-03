import '../models/esim.dart';

/// Service for fetching and managing user eSIM data.
///
/// Currently returns hard-coded dummy data. In production this should
/// call the backend API via [ApiService].
class ESIMService {
  /// Fetches all eSIMs belonging to the current user.
  static Future<List<ESIM>> fetchESIMs() async {
    // TODO: Replace with real API call
    // final response = await ApiService.get(
    //   ApiConfig.esimsEndpoint,
    //   queryParams: { 'page': '$page', 'limit': '$limit' },
    // );
    // final data = jsonDecode(response.body);
    await Future.delayed(const Duration(milliseconds: 500));

    final DateTime now = DateTime.now();

    return [
      ESIM(
        id: 'esim_001',
        country: 'Japan',
        flag: '🇯🇵',
        plan: '5 GB / 15 Days',
        dataUsed: 4.2,
        dataTotal: 5.0,
        daysLeft: 3,
        status: ESIMStatus.active,
        color: '#EAB308',
        purchaseDate: now.subtract(const Duration(days: 12)),
        activationDate: now.subtract(const Duration(days: 12)),
        iccid: '8912345678901234567',
        imsi: '310410987654321',
        ac: 'AC123456',
        shortUrl: 'https://esim.example.com/qr/jp001',
        originalStatus: 'IN_USE',
        remainingData: 0.8,
        remainingDataUnit: 'GB',
        expiredAt: now.add(const Duration(days: 3)),
        orderNo: 'ORD-20260601-001',
      ),
      ESIM(
        id: 'esim_002',
        country: 'Turkey',
        flag: '🇹🇷',
        plan: '3 GB / 7 Days',
        dataUsed: 0.0,
        dataTotal: 3.0,
        daysLeft: 7,
        status: ESIMStatus.new_,
        color: '#DC2626',
        purchaseDate: now,
        activationDate: null,
        iccid: '8912345678901234568',
        imsi: '286010987654322',
        ac: 'AC789012',
        shortUrl: 'https://esim.example.com/qr/tr001',
        originalStatus: 'GOT_RESOURCE',
        remainingData: 3.0,
        remainingDataUnit: 'GB',
        expiredAt: now.add(const Duration(days: 7)),
        orderNo: 'ORD-20260602-002',
      ),
      ESIM(
        id: 'esim_003',
        country: 'Indonesia',
        flag: '🇮🇩',
        plan: '1 GB / 30 Days',
        dataUsed: 0.9,
        dataTotal: 1.0,
        daysLeft: 2,
        status: ESIMStatus.lowData,
        color: '#EF4444',
        purchaseDate: now.subtract(const Duration(days: 28)),
        activationDate: now.subtract(const Duration(days: 28)),
        iccid: '8912345678901234569',
        imsi: '510110987654323',
        ac: 'AC345678',
        shortUrl: 'https://esim.example.com/qr/id001',
        originalStatus: 'IN_USE',
        remainingData: 0.1,
        remainingDataUnit: 'GB',
        expiredAt: now.add(const Duration(days: 2)),
        orderNo: 'ORD-20260504-003',
      ),
      ESIM(
        id: 'esim_004',
        country: 'United Kingdom',
        flag: '🇬🇧',
        plan: 'Unlimited / 30 Days',
        dataUsed: 12.4,
        dataTotal: 999.0,
        daysLeft: 0,
        status: ESIMStatus.expired,
        color: '#1E40AF',
        purchaseDate: now.subtract(const Duration(days: 31)),
        activationDate: now.subtract(const Duration(days: 30)),
        iccid: '8912345678901234570',
        imsi: '234100987654324',
        ac: 'AC901234',
        shortUrl: 'https://esim.example.com/qr/gb001',
        originalStatus: 'EXPIRED',
        remainingData: 0,
        remainingDataUnit: 'GB',
        expiredAt: now.subtract(const Duration(days: 1)),
        orderNo: 'ORD-20260501-004',
      ),
    ];
  }
}