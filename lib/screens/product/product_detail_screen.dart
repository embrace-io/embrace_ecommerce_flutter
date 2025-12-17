import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../widgets/product_card.dart';
import '../../utils/constants.dart';

/// ProductDetailScreen - Detailed product view with add to cart
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final EmbraceService _embrace = EmbraceService.shared;
  final ApiService _apiService = ApiService.shared;

  Product? _product;
  List<Product> _relatedProducts = [];
  bool _isLoading = true;
  String? _error;
  int _quantity = 1;
  int _currentImageIndex = 0;
  Map<String, String> _selectedVariants = {};

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final product = await _apiService.fetchProduct(widget.productId);
      if (product != null) {
        final relatedProducts = await _apiService.fetchRelatedProducts(widget.productId);

        setState(() {
          _product = product;
          _relatedProducts = relatedProducts;
          _isLoading = false;
        });

        // Track product view
        await _embrace.trackProductView(
          product.id,
          product.name,
          category: product.category,
          price: product.price,
        );
      } else {
        setState(() {
          _error = 'Product not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load product';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: AppConstants.spacingMd),
              Text(_error ?? 'Product not found'),
              const SizedBox(height: AppConstants.spacingMd),
              ElevatedButton(
                onPressed: _loadProduct,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _ImageCarousel(
                imageUrls: product.imageUrls,
                currentIndex: _currentImageIndex,
                onPageChanged: (index) {
                  setState(() => _currentImageIndex = index);
                },
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon!')),
                  );
                },
              ),
            ],
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),

                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),

                  // Price
                  Text(
                    product.formattedPrice,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),

                  // Stock Status
                  Row(
                    children: [
                      Icon(
                        product.inStock ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: product.inStock ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.inStock
                            ? 'In Stock${product.stockCount != null ? ' (${product.stockCount})' : ''}'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: product.inStock ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppConstants.spacingLg),

                  // Variants
                  if (product.variants.isNotEmpty) ...[
                    _VariantSelector(
                      variants: product.variants,
                      selectedVariants: _selectedVariants,
                      onVariantSelected: (type, value) {
                        setState(() {
                          _selectedVariants[type] = value;
                        });
                      },
                    ),
                    const Divider(height: AppConstants.spacingLg),
                  ],

                  // Quantity Selector
                  _QuantitySelector(
                    quantity: _quantity,
                    onChanged: (value) {
                      setState(() => _quantity = value);
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: product.inStock ? _addToCart : null,
                      icon: const Icon(Icons.shopping_cart),
                      label: Text(
                        product.inStock ? 'Add to Cart' : 'Out of Stock',
                      ),
                    ),
                  ),
                  const Divider(height: AppConstants.spacingLg),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(product.description),
                  const Divider(height: AppConstants.spacingLg),

                  // Related Products
                  if (_relatedProducts.isNotEmpty) ...[
                    Text(
                      'Related Products',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppConstants.spacingMd),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _relatedProducts.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < _relatedProducts.length - 1
                                  ? AppConstants.spacingMd
                                  : 0,
                            ),
                            child: SizedBox(
                              width: 180,
                              child: ProductCard(product: _relatedProducts[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(
      _product!,
      quantity: _quantity,
      selectedVariants: _selectedVariants.isNotEmpty ? _selectedVariants : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product!.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }
}

class _ImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageCarousel({
    required this.imageUrls,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(child: Icon(Icons.image, size: 64)),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.error),
              ),
            );
          },
        ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentIndex
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _VariantSelector extends StatelessWidget {
  final List<ProductVariant> variants;
  final Map<String, String> selectedVariants;
  final Function(String type, String value) onVariantSelected;

  const _VariantSelector({
    required this.variants,
    required this.selectedVariants,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Group variants by type
    final variantsByType = <VariantType, List<ProductVariant>>{};
    for (final variant in variants) {
      variantsByType.putIfAbsent(variant.type, () => []).add(variant);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variantsByType.entries.map((entry) {
        final typeName = entry.key.name;
        final typeVariants = entry.value;
        final selectedValue = selectedVariants[typeName];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              typeName[0].toUpperCase() + typeName.substring(1),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Wrap(
              spacing: AppConstants.spacingSm,
              runSpacing: AppConstants.spacingSm,
              children: typeVariants.map((variant) {
                final isSelected = selectedValue == variant.value;
                return ChoiceChip(
                  label: Text(variant.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      onVariantSelected(typeName, variant.value);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppConstants.spacingMd),
          ],
        );
      }).toList(),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Quantity',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
                child: Text(
                  '$quantity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(quantity + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
