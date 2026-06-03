/// Represents a geographic region (continent) that groups countries.
///
/// Mirrors the `Region` table in the database schema.
class Region {
  final String id;
  final String name;
  final String code;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Region({
    required this.id,
    required this.name,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// A sub-region / country within a [Region].
///
/// Mirrors the `SubRegion` table.
class SubRegion {
  final String id;
  final String name;
  final String code;
  final String regionId;

  const SubRegion({
    required this.id,
    required this.name,
    required this.code,
    required this.regionId,
  });
}