/// Represents a single data package (eSIM plan) that can be purchased.
class Package {
  final String id;
  final String name;
  final String code;
  final int duration;
  final String durationUnit; // DAY, WEEK, MONTH, YEAR
  final double price;
  final String data; // "3" or "Unlimited"
  final String dataUnit; // "GB", "MB", "" (empty for unlimited)
  final double pricePerData;
  final String regionId;
  final bool supports5G;
  final bool isUnlimited;
  final bool isBestSeller;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Package({
    required this.id,
    required this.name,
    required this.code,
    required this.duration,
    required this.durationUnit,
    required this.price,
    required this.data,
    required this.dataUnit,
    required this.pricePerData,
    required this.regionId,
    this.supports5G = false,
    this.isUnlimited = false,
    this.isBestSeller = false,
    this.createdAt,
    this.updatedAt,
  });
}