import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';
import '../models/package.dart';

// =============================================================================
// CHECKOUT STATE
// =============================================================================

/// Represents the current state of the checkout flow.
enum CheckoutStep { reviewing, processing, success, failed }

/// The selected payment method.
enum PaymentMethod { deposit, paypal, telegramStars, ton }

// =============================================================================
// STATE NOTIFIER
// =============================================================================

/// Manages the entire checkout state: selected plan, payment method, promo
/// code, quantity, balance, and the asynchronous payment process.
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier()
      : super(
          const CheckoutState(
            step: CheckoutStep.reviewing,
          ),
        );

  Timer? _pollTimer;
  int _pollAttempts = 0;
  static const int _maxPollAttempts = 30;
  static const Duration _pollInterval = Duration(seconds: 3);

  // ---------------------------------------------------------------------------
  // SETTERS
  // ---------------------------------------------------------------------------

  void setCountry(Location? country) {
    state = state.copyWith(country: country);
  }

  void setPackage(Package? package) {
    state = state.copyWith(package: package, quantity: 1);
  }

  void setQuantity(int qty) {
    if (qty < 1) qty = 1;
    state = state.copyWith(quantity: qty);
  }

  void setPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setUseDeposit(bool value) {
    state = state.copyWith(
      useDeposit: value,
      paymentMethod: value ? null : state.paymentMethod,
    );
  }

  void setPromoCode(String code) {
    state = state.copyWith(promoCode: code);
  }

  // ---------------------------------------------------------------------------
  // COMPUTED
  // ---------------------------------------------------------------------------

  /// Total price in USD.
  double get totalPrice {
    if (state.package == null) return 0;
    return state.package!.price * state.quantity;
  }

  // ---------------------------------------------------------------------------
  // FETCH BALANCE (MOCK)
  // ---------------------------------------------------------------------------

  Future<void> fetchBalance() async {
    state = state.copyWith(isLoadingBalance: true);
    try {
      // ---- MOCK DATA (replace with real /api/balance call) ----
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(balance: 75.50, isLoadingBalance: false);
    } catch (e) {
      state = state.copyWith(isLoadingBalance: false, errorMessage: e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // PROCESS PAYMENT
  // ---------------------------------------------------------------------------

  /// Entry point for processing payment. Routes to the correct handler
  /// based on the selected [PaymentMethod].
  Future<void> processPayment() async {
    if (state.package == null) return;

    state = state.copyWith(step: CheckoutStep.processing, errorMessage: null);

    switch (state.paymentMethod) {
      case PaymentMethod.deposit:
        await _processDeposit();
        break;
      case PaymentMethod.paypal:
        await _processPayPal();
        break;
      case PaymentMethod.telegramStars:
        await _processTelegramStars();
        break;
      case PaymentMethod.ton:
        await _processTON();
        break;
      case null:
        state = state.copyWith(
          step: CheckoutStep.reviewing,
          errorMessage: 'Please select a payment method.',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // DEPOSIT (internal balance)
  // ---------------------------------------------------------------------------

  Future<void> _processDeposit() async {
    if (state.balance < totalPrice) {
      state = state.copyWith(
        step: CheckoutStep.failed,
        errorMessage:
            'Insufficient balance. You have \$${state.balance.toStringAsFixed(2)} '
            'but need \$${totalPrice.toStringAsFixed(2)}.',
      );
      return;
    }

    // Deduct balance locally (in production this would be a server call)
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(
      step: CheckoutStep.success,
      balance: state.balance - totalPrice,
      orderNo: 'ORD-DEP-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ---------------------------------------------------------------------------
  // PAYPAL (external redirect)
  // ---------------------------------------------------------------------------

  Future<void> _processPayPal() async {
    // 1. Create PayPal order via backend
    final String? payLink = await _createPayPalOrder();
    if (payLink == null) {
      state = state.copyWith(
        step: CheckoutStep.failed,
        errorMessage: 'Failed to create PayPal order. Please try again.',
      );
      return;
    }

    state = state.copyWith(payLink: payLink);

    // 2. Start polling the order status
    final String referenceId = 'PAYPAL-${DateTime.now().millisecondsSinceEpoch}';
    state = state.copyWith(referenceId: referenceId);
    _startPolling(referenceId);
  }

  Future<String?> _createPayPalOrder() async {
    // ---- MOCK (replace with real /api/paypal/create call) ----
    await Future.delayed(const Duration(milliseconds: 800));
    return 'https://www.sandbox.paypal.com/checkoutnow?token=MOCK_TOKEN';
  }

  // ---------------------------------------------------------------------------
  // TELEGRAM STARS
  // ---------------------------------------------------------------------------

  Future<void> _processTelegramStars() async {
    // In production this would open a Telegram invoice.
    // For now, simulate success after a delay.
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(
      step: CheckoutStep.success,
      orderNo: 'ORD-STARS-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ---------------------------------------------------------------------------
  // TON (crypto)
  // ---------------------------------------------------------------------------

  Future<void> _processTON() async {
    // In production this would initiate a TON Connect transaction.
    // For now, simulate success after a delay.
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(
      step: CheckoutStep.success,
      orderNo: 'ORD-TON-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  // ---------------------------------------------------------------------------
  // ORDER POLLING
  // ---------------------------------------------------------------------------

  void _startPolling(String referenceId) {
    _pollAttempts = 0;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      await _pollOrderStatus(referenceId);
    });
  }

  Future<void> _pollOrderStatus(String referenceId) async {
    _pollAttempts++;
    if (_pollAttempts > _maxPollAttempts) {
      _pollTimer?.cancel();
      state = state.copyWith(
        step: CheckoutStep.failed,
        errorMessage:
            'Payment verification timed out. Please check your orders manually.',
      );
      return;
    }

    // ---- MOCK (replace with real /api/orders polling) ----
    // Simulate: after ~6 seconds (2 polls) the payment completes.
    if (_pollAttempts >= 2) {
      _pollTimer?.cancel();
      state = state.copyWith(
        step: CheckoutStep.success,
        orderNo: 'ORD-PP-${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    _pollTimer?.cancel();
    _pollAttempts = 0;
    state = const CheckoutState(step: CheckoutStep.reviewing);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

// =============================================================================
// STATE CLASS
// =============================================================================

class CheckoutState {
  final CheckoutStep step;
  final Location? country;
  final Package? package;
  final int quantity;
  final PaymentMethod? paymentMethod;
  final bool useDeposit;
  final String promoCode;
  final double balance;
  final bool isLoadingBalance;
  final String? errorMessage;
  final String? payLink;
  final String? referenceId;
  final String? orderNo;

  const CheckoutState({
    required this.step,
    this.country,
    this.package,
    this.quantity = 1,
    this.paymentMethod,
    this.useDeposit = false,
    this.promoCode = '',
    this.balance = 0,
    this.isLoadingBalance = false,
    this.errorMessage,
    this.payLink,
    this.referenceId,
    this.orderNo,
  });

  CheckoutState copyWith({
    CheckoutStep? step,
    Location? country,
    Package? package,
    int? quantity,
    PaymentMethod? paymentMethod,
    bool? useDeposit,
    String? promoCode,
    double? balance,
    bool? isLoadingBalance,
    String? errorMessage,
    String? payLink,
    String? referenceId,
    String? orderNo,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      country: country ?? this.country,
      package: package ?? this.package,
      quantity: quantity ?? this.quantity,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      useDeposit: useDeposit ?? this.useDeposit,
      promoCode: promoCode ?? this.promoCode,
      balance: balance ?? this.balance,
      isLoadingBalance: isLoadingBalance ?? this.isLoadingBalance,
      errorMessage: errorMessage,
      payLink: payLink ?? this.payLink,
      referenceId: referenceId ?? this.referenceId,
      orderNo: orderNo ?? this.orderNo,
    );
  }
}

// =============================================================================
// PROVIDERS
// =============================================================================

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(),
);