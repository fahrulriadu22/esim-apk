import '../models/enums.dart';
import '../models/order.dart';

/// Service for creating and fetching orders.
///
/// Currently returns hard-coded dummy data. In production this should
/// call the backend API via [ApiService].
class OrderService {
  /// Creates a new order for the specified package.
  static Future<Order> createOrder({
    required String packageCode,
    required double price,
    required int count,
    required bool useDeposit,
  }) async {
    // TODO: Replace with real API call
    // final response = await ApiService.post(
    //   ApiConfig.createOrderEndpoint,
    //   body: { 'packageCode': packageCode, 'price': price, 'count': count, 'useDeposit': useDeposit },
    // );
    // final data = jsonDecode(response.body);
    await Future.delayed(const Duration(seconds: 1));

    return Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      country: 'Indonesia',
      flag: '🇮🇩',
      plan: '5 GB / 15 Days',
      price: price,
      status: OrderStatus.completed,
      orderDate: DateTime.now(),
      paymentMethod: useDeposit ? 'Deposit' : 'PayPal',
      color: '#10B981',
      txId: 'TX-${DateTime.now().millisecondsSinceEpoch}',
      packageCode: packageCode,
    );
  }

  /// Fetches paginated orders for the current user.
  static Future<List<Order>> fetchOrders({
    int page = 1,
    int limit = 5,
  }) async {
    // TODO: Replace with real API call
    // final response = await ApiService.get(
    //   ApiConfig.ordersEndpoint,
    //   queryParams: { 'page': '$page', 'limit': '$limit' },
    // );
    // final data = jsonDecode(response.body);
    await Future.delayed(const Duration(milliseconds: 600));

    final DateTime now = DateTime.now();

    return [
      Order(
        id: 'ORD-20260610-001',
        country: 'Japan',
        flag: '🇯🇵',
        plan: '5 GB / 15 Days',
        price: 7.99,
        status: OrderStatus.completed,
        orderDate: now.subtract(const Duration(days: 2)),
        paymentMethod: 'PayPal',
        color: '#EAB308',
        txId: 'TX-001',
      ),
      Order(
        id: 'ORD-20260609-002',
        country: 'Turkey',
        flag: '🇹🇷',
        plan: '3 GB / 7 Days',
        price: 4.50,
        status: OrderStatus.completed,
        orderDate: now.subtract(const Duration(days: 5)),
        paymentMethod: 'Deposit',
        color: '#DC2626',
        txId: 'TX-002',
      ),
      Order(
        id: 'ORD-20260608-003',
        country: 'Indonesia',
        flag: '🇮🇩',
        plan: '1 GB / 30 Days',
        price: 3.50,
        status: OrderStatus.pending,
        orderDate: now.subtract(const Duration(hours: 3)),
        paymentMethod: 'Telegram Stars',
        color: '#EF4444',
        txId: 'TX-003',
      ),
    ];
  }
}