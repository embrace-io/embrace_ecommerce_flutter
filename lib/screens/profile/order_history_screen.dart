import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';

/// OrderHistoryScreen - View past orders
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock orders for demo - in real app, fetch from API
    final orders = <Order>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: orders.isEmpty
          ? _EmptyOrders()
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return _OrderCard(order: orders[index]);
              },
            ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const Text('No orders yet'),
          const SizedBox(height: AppConstants.spacingSm),
          const Text('Your order history will appear here'),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              '${order.totalItems} items - ${order.formattedTotal}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              'Ordered on ${_formatDate(order.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            if (order.trackingNumber != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Tracking: ${order.trackingNumber}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Show order details
                  },
                  child: const Text('View Details'),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                if (order.status == OrderStatus.delivered)
                  TextButton(
                    onPressed: () {
                      // Reorder
                    },
                    child: const Text('Reorder'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
      case OrderStatus.processing:
        backgroundColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        backgroundColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
