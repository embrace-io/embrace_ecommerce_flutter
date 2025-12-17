import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/constants.dart';

/// CartScreen - Shopping cart with items and checkout button
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Track cart view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().trackCartViewed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              if (cart.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showClearCartDialog(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.isEmpty) {
            return _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingMd),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    return _CartItemTile(
                      item: cartProvider.items[index],
                      onQuantityChanged: (quantity) {
                        cartProvider.updateQuantity(
                          cartProvider.items[index].id,
                          quantity,
                        );
                      },
                      onRemove: () {
                        cartProvider.removeFromCart(cartProvider.items[index].id);
                      },
                    );
                  },
                ),
              ),
              _CartSummary(
                subtotal: cartProvider.subtotal,
                itemCount: cartProvider.totalItems,
                onCheckout: () => _navigateToCheckout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context) {
    final authProvider = context.read<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      // Prompt login before checkout
      showModalBottomSheet(
        context: context,
        builder: (context) => _CheckoutAuthPrompt(
          onContinueAsGuest: () {
            Navigator.pop(context);
            authProvider.continueAsGuest().then((_) {
              context.push('/checkout');
            });
          },
          onSignIn: () {
            Navigator.pop(context);
            context.push('/auth');
          },
        ),
      );
    } else {
      context.push('/checkout');
    }
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Text('Start shopping to add items to your cart'),
          const SizedBox(height: AppConstants.spacingLg),
          FilledButton.icon(
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
              child: CachedNetworkImage(
                imageUrl: item.product.primaryImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    '\$${item.unitPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  // Quantity controls
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onPressed: item.quantity > 1
                            ? () => onQuantityChanged(item.quantity - 1)
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMd,
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onPressed: () => onQuantityChanged(item.quantity + 1),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onRemove,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final int itemCount;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.itemCount,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal ($itemCount items)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMd),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onCheckout,
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutAuthPrompt extends StatelessWidget {
  final VoidCallback onContinueAsGuest;
  final VoidCallback onSignIn;

  const _CheckoutAuthPrompt({
    required this.onContinueAsGuest,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 48),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'Sign in for a better experience',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.spacingSm),
          const Text(
            'Track orders, save addresses, and checkout faster',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingLg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSignIn,
              child: const Text('Sign In'),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onContinueAsGuest,
              child: const Text('Continue as Guest'),
            ),
          ),
        ],
      ),
    );
  }
}
