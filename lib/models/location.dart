/// Represents a country or region where eSIM data plans are available.
class Location {
  final String name;
  final String color;
  final String code;
  final String flag;
  final double? cheapestPrice;
  final int? packageCount;
  final List<SubLocation>? subLocationList;

  const Location({
    required this.name,
    required this.color,
    required this.code,
    required this.flag,
    this.cheapestPrice,
    this.packageCount,
    this.subLocationList,
  });
}

/// Represents a sub-location (e.g., a country within a continent/region).
class SubLocation {
  final String code;
  final String name;

  const SubLocation({
    required this.code,
    required this.name,
  });
}