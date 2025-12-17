import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../utils/constants.dart';

/// CheckoutScreen - Multi-step checkout flow
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final EmbraceService _embrace = EmbraceService.shared;

  @override
  void initState() {
    super.initState();
    // Reset checkout provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final checkoutProvider = context.read<CheckoutProvider>();
      final cartProvider = context.read<CartProvider>();
      checkoutProvider.reset();

      _embrace.trackCheckoutStarted(
        cartProvider.totalItems,
        cartProvider.subtotal,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CheckoutProvider, CartProvider>(
      builder: (context, checkoutProvider, cartProvider, _) {
        if (cartProvider.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64),
                  const SizedBox(height: AppConstants.spacingMd),
                  const Text('Your cart is empty'),
                  const SizedBox(height: AppConstants.spacingMd),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Checkout'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // Progress Indicator
              _CheckoutProgress(currentStep: checkoutProvider.currentStepIndex),

              // Content
              Expanded(
                child: _buildStepContent(checkoutProvider, cartProvider),
              ),

              // Bottom Bar
              _BottomBar(
                checkoutProvider: checkoutProvider,
                cartProvider: cartProvider,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(
    CheckoutProvider checkoutProvider,
    CartProvider cartProvider,
  ) {
    switch (checkoutProvider.currentStep) {
      case CheckoutStep.cartReview:
        return _CartReviewStep(cartProvider: cartProvider);
      case CheckoutStep.shipping:
        return _ShippingStep(checkoutProvider: checkoutProvider);
      case CheckoutStep.payment:
        return _PaymentStep(checkoutProvider: checkoutProvider);
      case CheckoutStep.confirmation:
        return _ConfirmationStep(
          checkoutProvider: checkoutProvider,
          cartProvider: cartProvider,
        );
    }
  }
}

class _CheckoutProgress extends StatelessWidget {
  final int currentStep;

  const _CheckoutProgress({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Cart', 'Shipping', 'Payment', 'Confirm'];

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step Circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                // Connector Line
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CartReviewStep extends StatelessWidget {
  final CartProvider cartProvider;

  const _CartReviewStep({required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        Text(
          'Review Your Cart',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppConstants.spacingMd),
        ...cartProvider.items.map((item) => _CartItemSummary(item: item)),
        const Divider(height: AppConstants.spacingLg),
        _SummaryRow(
          label: 'Subtotal (${cartProvider.totalItems} items)',
          value: cartProvider.formattedSubtotal,
        ),
      ],
    );
  }
}

class _CartItemSummary extends StatelessWidget {
  final CartItem item;

  const _CartItemSummary({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSm),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(Icons.image),
        ),
        title: Text(item.product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('Qty: ${item.quantity}'),
        trailing: Text(
          '\$${item.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ShippingStep extends StatefulWidget {
  final CheckoutProvider checkoutProvider;

  const _ShippingStep({required this.checkoutProvider});

  @override
  State<_ShippingStep> createState() => _ShippingStepState();
}

class _ShippingStepState extends State<_ShippingStep> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  ShippingMethod? _selectedShippingMethod;

  @override
  void initState() {
    super.initState();
    _selectedShippingMethod = widget.checkoutProvider.shippingMethod ??
        ShippingMethods.standard;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _saveShippingInfo() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        id: 'checkout_${DateTime.now().millisecondsSinceEpoch}',
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
      );

      widget.checkoutProvider.setShippingAddress(address);
      widget.checkoutProvider.setShippingMethod(_selectedShippingMethod!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: _saveShippingInfo,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          Text(
            'Shipping Address',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Name Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),

          TextFormField(
            controller: _streetController,
            decoration: const InputDecoration(labelText: 'Street Address'),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: AppConstants.spacingMd),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(labelText: 'State'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: TextFormField(
                  controller: _zipController,
                  decoration: const InputDecoration(labelText: 'ZIP'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
              ),
            ],
          ),
          const Divider(height: AppConstants.spacingLg),

          Text(
            'Shipping Method',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingMd),

          ...ShippingMethods.all.map((method) => RadioListTile<ShippingMethod>(
                title: Text(method.name),
                subtitle: Text('${method.estimatedDeliveryText} - ${method.formattedCost}'),
                value: method,
                groupValue: _selectedShippingMethod,
                onChanged: (value) {
                  setState(() => _selectedShippingMethod = value);
                  widget.checkoutProvider.setShippingMethod(value!);
                },
              )),
        ],
      ),
    );
  }
}

class _PaymentStep extends StatefulWidget {
  final CheckoutProvider checkoutProvider;

  const _PaymentStep({required this.checkoutProvider});

  @override
  State<_PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<_PaymentStep> {
  PaymentMethod? _selectedPaymentMethod;

  final _mockPaymentMethods = [
    PaymentMethod(
      id: 'mock_visa',
      type: PaymentType.creditCard,
      cardInfo: const CardInfo(
        last4: '4242',
        brand: 'Visa',
        expiryMonth: 12,
        expiryYear: 2025,
        holderName: 'Test Card',
      ),
    ),
    PaymentMethod(
      id: 'mock_mc',
      type: PaymentType.creditCard,
      cardInfo: const CardInfo(
        last4: '5555',
        brand: 'Mastercard',
        expiryMonth: 6,
        expiryYear: 2026,
        holderName: 'Test Card',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppConstants.spacingMd),

        ..._mockPaymentMethods.map((method) => RadioListTile<PaymentMethod>(
              title: Text(method.displayName),
              subtitle: method.cardInfo != null
                  ? Text('Expires ${method.cardInfo!.expiry}')
                  : null,
              secondary: const Icon(Icons.credit_card),
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() => _selectedPaymentMethod = value);
                widget.checkoutProvider.setPaymentMethod(value!);
              },
            )),

        const Divider(height: AppConstants.spacingLg),

        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Padding(
            padding: EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    'This is a demo app. No real payment will be processed.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationStep extends StatelessWidget {
  final CheckoutProvider checkoutProvider;
  final CartProvider cartProvider;

  const _ConfirmationStep({
    required this.checkoutProvider,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (checkoutProvider.state == CheckoutState.success &&
        checkoutProvider.completedOrder != null) {
      return _OrderSuccess(order: checkoutProvider.completedOrder!);
    }

    final subtotal = checkoutProvider.calculateSubtotal(cartProvider.items);
    final tax = checkoutProvider.calculateTax(subtotal);
    final shipping = checkoutProvider.shippingMethod?.cost ?? 0;
    final total = subtotal + tax + shipping;

    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        Text(
          'Order Summary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // Items
        ...cartProvider.items.map((item) => _CartItemSummary(item: item)),
        const Divider(),

        // Shipping Address
        if (checkoutProvider.shippingAddress != null) ...[
          _InfoSection(
            title: 'Shipping Address',
            content: checkoutProvider.shippingAddress!.formattedAddress,
          ),
        ],

        // Shipping Method
        if (checkoutProvider.shippingMethod != null) ...[
          _InfoSection(
            title: 'Shipping Method',
            content: '${checkoutProvider.shippingMethod!.name} - ${checkoutProvider.shippingMethod!.formattedCost}',
          ),
        ],

        // Payment Method
        if (checkoutProvider.paymentMethod != null) ...[
          _InfoSection(
            title: 'Payment Method',
            content: checkoutProvider.paymentMethod!.displayName,
          ),
        ],

        const Divider(),

        // Totals
        _SummaryRow(label: 'Subtotal', value: '\$${subtotal.toStringAsFixed(2)}'),
        _SummaryRow(label: 'Tax', value: '\$${tax.toStringAsFixed(2)}'),
        _SummaryRow(label: 'Shipping', value: shipping > 0 ? '\$${shipping.toStringAsFixed(2)}' : 'Free'),
        const Divider(),
        _SummaryRow(
          label: 'Total',
          value: '\$${total.toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }
}

class _OrderSuccess extends StatelessWidget {
  final Order order;

  const _OrderSuccess({required this.order});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              'Order Placed!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text('Order #${order.orderNumber}'),
            const SizedBox(height: AppConstants.spacingMd),
            Text(
              order.formattedTotal,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isBold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final CheckoutProvider checkoutProvider;
  final CartProvider cartProvider;

  const _BottomBar({
    required this.checkoutProvider,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isConfirmation = checkoutProvider.currentStep == CheckoutStep.confirmation;
    final isSuccess = checkoutProvider.state == CheckoutState.success;
    final canProceed = checkoutProvider.canProceed();
    final isLoading = checkoutProvider.isLoading;

    if (isSuccess) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (checkoutProvider.currentStepIndex > 0)
              OutlinedButton(
                onPressed: isLoading ? null : () => checkoutProvider.goToPreviousStep(),
                child: const Text('Back'),
              ),
            if (checkoutProvider.currentStepIndex > 0)
              const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: FilledButton(
                onPressed: isLoading || (!canProceed && !isConfirmation)
                    ? null
                    : () => _handleNext(context),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isConfirmation ? 'Place Order' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext(BuildContext context) async {
    if (checkoutProvider.currentStep == CheckoutStep.confirmation) {
      final authProvider = context.read<AuthProvider>();
      final success = await checkoutProvider.placeOrder(
        cartProvider.items,
        userId: authProvider.currentUser?.id,
      );

      if (success) {
        cartProvider.clearCart();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkoutProvider.errorMessage ?? 'Order failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      checkoutProvider.goToNextStep();
    }
  }
}
