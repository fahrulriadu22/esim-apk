import 'package:flutter/material.dart';

/// Displays the user's order history with infinite scroll pagination.
///
/// In a real implementation this would use a Riverpod provider that calls
/// `/api/orders` with pagination. For now it shows hard‑coded dummy data
/// that demonstrates the UI structure.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;

  // ---- MOCK ORDERS ----
  final List<_Order> _orders = [
    _Order(
      id: 'ORD-20260610-001',
      country: 'Japan',
      flag: '🇯🇵',
      plan: '5 GB / 15 Days',
      price: 7.99,
      status: _OrderStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'PayPal',
    ),
    _Order(
      id: 'ORD-20260609-002',
      country: 'Turkey',
      flag: '🇹🇷',
      plan: '3 GB / 7 Days',
      price: 4.50,
      status: _OrderStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 5)),
      paymentMethod: 'Deposit',
    ),
    _Order(
      id: 'ORD-20260608-003',
      country: 'Indonesia',
      flag: '🇮🇩',
      plan: '1 GB / 30 Days',
      price: 3.50,
      status: _OrderStatus.pending,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      paymentMethod: 'Telegram Stars',
    ),
    _Order(
      id: 'ORD-20260607-004',
      country: 'United Kingdom',
      flag: '🇬🇧',
      plan: 'Unlimited / 30 Days',
      price: 24.99,
      status: _OrderStatus.failed,
      date: DateTime.now().subtract(const Duration(days: 10)),
      paymentMethod: 'TON',
    ),
    _Order(
      id: 'ORD-20260601-005',
      country: 'France',
      flag: '🇫🇷',
      plan: '10 GB / 30 Days',
      price: 12.99,
      status: _OrderStatus.completed,
      date: DateTime.now().subtract(const Duration(days: 12)),
      paymentMethod: 'PayPal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _hasMore = false;
      _isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _orders.isEmpty
            ? _buildEmptyState(theme)
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= _orders.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _OrderCard(
                    order: _orders[index],
                    cs: cs,
                    theme: theme,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'No orders yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// ORDER CARD
// =============================================================================

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.cs,
    required this.theme,
  });

  final _Order order;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(order.flag, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.country,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        order.plan,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${order.price.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                Text(
                  order.paymentMethod,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  _formatDate(order.date),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Order: ${order.id}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

// =============================================================================
// STATUS BADGE
// =============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final _OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color bg, Color fg) = switch (status) {
      _OrderStatus.completed => (
        'COMPLETED',
        Colors.green.shade100,
        Colors.green.shade800,
      ),
      _OrderStatus.pending => (
        'PENDING',
        Colors.orange.shade100,
        Colors.orange.shade900,
      ),
      _OrderStatus.failed => (
        'FAILED',
        Colors.red.shade100,
        Colors.red.shade800,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// =============================================================================
// LOCAL DATA MODELS
// =============================================================================

enum _OrderStatus { completed, pending, failed }

class _Order {
  final String id;
  final String country;
  final String flag;
  final String plan;
  final double price;
  final _OrderStatus status;
  final DateTime date;
  final String paymentMethod;

  const _Order({
    required this.id,
    required this.country,
    required this.flag,
    required this.plan,
    required this.price,
    required this.status,
    required this.date,
    required this.paymentMethod,
  });
}