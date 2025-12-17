import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../utils/constants.dart';

/// CartItemTile - Reusable cart item widget
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onRemove;
  final bool showControls;

  const CartItemTile({
    super.key,
    required this.item,
    this.onQuantityChanged,
    this.onRemove,
    this.showControls = true,
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
                  if (showControls) ...[
                    const SizedBox(height: AppConstants.spacingSm),
                    Row(
                      children: [
                        _QuantityButton(
                          icon: Icons.remove,
                          onPressed: item.quantity > 1 && onQuantityChanged != null
                              ? () => onQuantityChanged!(item.quantity - 1)
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
                          onPressed: onQuantityChanged != null
                              ? () => onQuantityChanged!(item.quantity + 1)
                              : null,
                        ),
                        const Spacer(),
                        if (onRemove != null)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: onRemove,
                            color: Theme.of(context).colorScheme.error,
                          ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      'Qty: ${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            // Total Price
            if (!showControls)
              Text(
                '\$${item.totalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
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
