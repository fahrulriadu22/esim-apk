/// Represents the lifecycle status of an eSIM assigned to a user.
///
/// Mirrors the database/webhook statuses from the Next.js backend.
enum ESIMStatus {
  /// Just created, not yet activated.
  new_,

  /// Currently in use with sufficient remaining data.
  active,

  /// In use but remaining data is critically low.
  lowData,

  /// Data plan has expired.
  expired,
}

/// Represents the processing status of an order.
///
/// Mirrors the `OrderStatus` enum in the database schema.
enum OrderStatus {
  /// Order has been created but payment is not yet confirmed.
  pending,

  /// Payment confirmed, eSIM has been provisioned.
  completed,

  /// Payment failed or order was cancelled.
  failed,
}

/// Distinguishes between a top-up transaction and a package purchase.
///
/// Mirrors the `PaymentType` enum in the database schema.
enum PaymentType {
  /// Adding funds to the internal balance.
  topup,

  /// Purchasing one or more eSIM data packages.
  order,
}

/// The current state of a payment.
///
/// Mirrors the `PaymentStatus` enum in the database schema.
enum PaymentStatus {
  /// Payment initiated but not yet confirmed.
  pending,

  /// Payment successfully processed.
  completed,

  /// Payment attempt failed.
  failed,
}