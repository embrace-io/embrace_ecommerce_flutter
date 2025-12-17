import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import '../../utils/constants.dart';

/// HomeScreen - Main landing screen with featured products, categories, and deals
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.hasError) {
            return _ErrorView(
              message: productProvider.errorMessage ?? 'Failed to load products',
              onRetry: () => productProvider.refreshData(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => productProvider.refreshData(),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              children: [
                // Categories Section
                _SectionHeader(
                  title: 'Categories',
                  onSeeAll: () => context.push('/products'),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                _CategoriesGrid(categories: productProvider.categories),
                const SizedBox(height: AppConstants.spacingLg),

                // Featured Products Section
                _SectionHeader(
                  title: 'Featured Products',
                  onSeeAll: () => context.push('/products'),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                _ProductsHorizontalList(
                  products: productProvider.featuredProducts,
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // Daily Deals Section
                _SectionHeader(
                  title: 'Daily Deals',
                  trailing: _CountdownTimer(),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                _ProductsHorizontalList(
                  products: productProvider.dailyDeals,
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // New Arrivals Section
                _SectionHeader(
                  title: 'New Arrivals',
                  onSeeAll: () => context.push('/products'),
                ),
                const SizedBox(height: AppConstants.spacingSm),
                _ProductsGrid(products: productProvider.newArrivals),
                const SizedBox(height: AppConstants.spacingLg),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (trailing != null)
          trailing!
        else if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final List<Category> categories;

  const _CategoriesGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1 ? AppConstants.spacingSm : 0,
            ),
            child: _CategoryCard(category: category),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/products?category=${category.id}'),
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category.id),
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.spacingXs),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'electronics':
        return Icons.devices;
      case 'fashion':
        return Icons.checkroom;
      case 'home':
        return Icons.home;
      case 'sports':
        return Icons.sports_basketball;
      case 'books':
        return Icons.menu_book;
      case 'beauty':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }
}

class _ProductsHorizontalList extends StatelessWidget {
  final List<Product> products;

  const _ProductsHorizontalList({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < products.length - 1 ? AppConstants.spacingMd : 0,
            ),
            child: SizedBox(
              width: 180,
              child: ProductCard(product: products[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ProductsGrid extends StatelessWidget {
  final List<Product> products;

  const _ProductsGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.spacingMd,
        mainAxisSpacing: AppConstants.spacingMd,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSm,
        vertical: AppConstants.spacingXs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 4),
          Text(
            '23:59:59',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: AppConstants.spacingMd),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppConstants.spacingMd),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
