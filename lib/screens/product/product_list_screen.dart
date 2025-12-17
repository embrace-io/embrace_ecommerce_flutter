import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import '../../utils/constants.dart';

/// ProductListScreen - Grid view of products with filtering
class ProductListScreen extends StatefulWidget {
  final String? category;

  const ProductListScreen({super.key, this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? _selectedCategory;
  String _sortBy = 'default';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _loadProducts();
  }

  void _loadProducts() {
    if (_selectedCategory != null) {
      context.read<ProductProvider>().loadProductsByCategory(_selectedCategory!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory != null
            ? _selectedCategory![0].toUpperCase() + _selectedCategory!.substring(1)
            : 'All Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final products = _selectedCategory != null
              ? provider.categoryProducts
              : [...provider.featuredProducts, ...provider.newArrivals];

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: AppConstants.spacingMd),
                  const Text('No products found'),
                  const SizedBox(height: AppConstants.spacingMd),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Browse All'),
                  ),
                ],
              ),
            );
          }

          final sortedProducts = _sortProducts(products);

          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: AppConstants.spacingMd,
              mainAxisSpacing: AppConstants.spacingMd,
            ),
            itemCount: sortedProducts.length,
            itemBuilder: (context, index) {
              return ProductCard(product: sortedProducts[index]);
            },
          );
        },
      ),
    );
  }

  List<Product> _sortProducts(List<Product> products) {
    final sorted = List<Product>.from(products);

    switch (_sortBy) {
      case 'price_low':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        // Keep original order
        break;
    }

    return sorted;
  }

  void _showFilterSheet() {
    final categories = context.read<ProductProvider>().categories;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter by Category',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedCategory = null;
                          });
                          setState(() {
                            _selectedCategory = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Wrap(
                    spacing: AppConstants.spacingSm,
                    runSpacing: AppConstants.spacingSm,
                    children: categories.map<Widget>((category) {
                      final isSelected = _selectedCategory == category.id;
                      return FilterChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedCategory = selected ? category.id : null;
                          });
                          setState(() {
                            _selectedCategory = selected ? category.id : null;
                          });
                          if (selected) {
                            _loadProducts();
                          }
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingMd),
              _SortOption(
                label: 'Default',
                value: 'default',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Price: Low to High',
                value: 'price_low',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Price: High to Low',
                value: 'price_high',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
              _SortOption(
                label: 'Name: A to Z',
                value: 'name',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SortOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
