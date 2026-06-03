import 'enums.dart';

/// Represents a purchase order in the eSIM Marketplace.
///
/// Mirrors the `Order` table and the `useOrders` hook from the Next.js backend.
class Order {
  final String id;
  final String country;
  final String flag;
  final String plan;
  final double price;
  final OrderStatus status;
  final DateTime orderDate;
  final DateTime? activationDate;
  final String paymentMethod;
  final String color;
  final String txId;
  final String? packageCode;
  final List<OrderESIM> esims;

  const Order({
    required this.id,
    required this.country,
    required this.flag,
    required this.plan,
    required this.price,
    required this.status,
    required this.orderDate,
    this.activationDate,
    required this.paymentMethod,
    required this.color,
    required this.txId,
    this.packageCode,
    this.esims = const [],
  });
}

/// A single eSIM record inside an [Order].
///
/// Mirrors the `OrderEsim` interface from the `useOrders` hook.
class OrderESIM {
  final String id;
  final String iccid;
  final String imsi;
  final String ac;
  final String status;
  final int remainingData;
  final String remainingDataUnit;
  final DateTime expiredAt;

  const OrderESIM({
    required this.id,
    required this.iccid,
    required this.imsi,
    required this.ac,
    required this.status,
    required this.remainingData,
    required this.remainingDataUnit,
    required this.expiredAt,
  });
}