/// Represents an authenticated Telegram user in the eSIM Marketplace.
///
/// Mirrors the `User` table in the database schema.
class User {
  final String id;
  final String telegramId;
  final String username;
  final String fullName;
  final String? photoUrl;
  final String? languageCode;
  final String balanceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.telegramId,
    required this.username,
    required this.fullName,
    this.photoUrl,
    this.languageCode,
    required this.balanceId,
    required this.createdAt,
    required this.updatedAt,
  });
}