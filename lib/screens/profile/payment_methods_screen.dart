import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';

/// PaymentMethodsScreen - Manage saved payment methods
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Mock payment methods for demo
  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: PaymentType.creditCard,
      isDefault: true,
      cardInfo: const CardInfo(
        last4: '4242',
        brand: 'Visa',
        expiryMonth: 12,
        expiryYear: 2025,
        holderName: 'John Doe',
      ),
    ),
    PaymentMethod(
      id: '2',
      type: PaymentType.creditCard,
      isDefault: false,
      cardInfo: const CardInfo(
        last4: '1234',
        brand: 'Mastercard',
        expiryMonth: 6,
        expiryYear: 2026,
        holderName: 'John Doe',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: _paymentMethods.isEmpty
          ? _EmptyPaymentMethods()
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                return _PaymentMethodCard(
                  paymentMethod: _paymentMethods[index],
                  onDelete: () => _deletePaymentMethod(_paymentMethods[index]),
                  onSetDefault: () => _setDefaultPaymentMethod(_paymentMethods[index]),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPaymentMethod,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addPaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add payment method coming soon!')),
    );
  }

  void _deletePaymentMethod(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((p) => p.id == method.id);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _setDefaultPaymentMethod(PaymentMethod method) {
    setState(() {
      for (var i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i] = _paymentMethods[i].copyWith(
          isDefault: _paymentMethods[i].id == method.id,
        );
      }
    });
  }
}

class _EmptyPaymentMethods extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          const Text('No saved payment methods'),
          const SizedBox(height: AppConstants.spacingSm),
          const Text('Add a payment method for faster checkout'),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _PaymentMethodCard({
    required this.paymentMethod,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final cardInfo = paymentMethod.cardInfo;

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCardIcon(cardInfo?.brand),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paymentMethod.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (cardInfo != null)
                        Text(
                          'Expires ${cardInfo.expiry}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                if (paymentMethod.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
                if (!paymentMethod.isDefault) ...[
                  const Spacer(),
                  TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set as Default'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCardIcon(String? brand) {
    switch (brand?.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}
