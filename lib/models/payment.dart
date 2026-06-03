import 'enums.dart';

/// Represents a payment transaction in the system.
///
/// Mirrors the `PaymentHistory` table in the database schema.
class Payment {
  final String id;
  final String referenceId;
  final String telegramId;
  final String? userId;
  final String? payerEmail;
  final double amount;
  final String? paymentMethod;
  final PaymentStatus status;
  final PaymentType paymentType;
  final String? orderNo;
  final String? packageCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Payment({
    required this.id,
    required this.referenceId,
    required this.telegramId,
    this.userId,
    this.payerEmail,
    required this.amount,
    this.paymentMethod,
    required this.status,
    required this.paymentType,
    this.orderNo,
    this.packageCode,
    required this.createdAt,
    required this.updatedAt,
  });
}