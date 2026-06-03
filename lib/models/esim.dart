/// Represents a user's eSIM with its current status, usage, and metadata.
class ESIM {
  final String id;
  final String country;
  final String flag;
  final String plan;
  final double dataUsed;
  final double dataTotal;
  final int daysLeft;
  final ESIMStatus status;
  final String color;
  final DateTime purchaseDate;
  final DateTime? activationDate;
  final String iccid;
  final String imsi;
  final String ac;
  final String shortUrl;
  final String originalStatus;
  final double remainingData;
  final String remainingDataUnit;
  final DateTime expiredAt;
  final String orderNo;

  const ESIM({
    required this.id,
    required this.country,
    required this.flag,
    required this.plan,
    required this.dataUsed,
    required this.dataTotal,
    required this.daysLeft,
    required this.status,
    required this.color,
    required this.purchaseDate,
    this.activationDate,
    required this.iccid,
    required this.imsi,
    required this.ac,
    required this.shortUrl,
    required this.originalStatus,
    required this.remainingData,
    required this.remainingDataUnit,
    required this.expiredAt,
    required this.orderNo,
  });

  /// The percentage of data consumed (0.0 to 1.0).
  double get dataUsagePercent =>
      dataTotal > 0 ? (dataUsed / dataTotal).clamp(0.0, 1.0) : 0.0;
}

enum ESIMStatus { new_, active, lowData, expired }