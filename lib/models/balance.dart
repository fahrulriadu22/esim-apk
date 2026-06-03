/// Represents a user's internal wallet balance.
///
/// Mirrors the `Balance` table in the database schema.
class Balance {
  final String id;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Balance({
    required this.id,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });
}