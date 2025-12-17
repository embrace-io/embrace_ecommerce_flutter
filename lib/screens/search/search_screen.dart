import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';
import '../../utils/constants.dart';
import '../../services/services.dart';

/// SearchScreen - Product search with recent searches and results
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final EmbraceService _embrace = EmbraceService.shared;

  Timer? _debounceTimer;
  List<String> _recentSearches = [];
  bool _showResults = false;

  static const _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_recentSearchesKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
    }
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    setState(() {});
  }

  Future<void> _removeRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    await prefs.setStringList(_recentSearchesKey, _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    setState(() {
      _recentSearches = [];
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() => _showResults = false);
      context.read<ProductProvider>().clearSearchResults();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() => _showResults = true);
      context.read<ProductProvider>().searchProducts(query);
      _saveRecentSearch(query);
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isEmpty) return;

    _saveRecentSearch(query);
    setState(() => _showResults = true);
    context.read<ProductProvider>().searchProducts(query);
    _focusNode.unfocus();
  }

  void _onRecentSearchTap(String query) {
    _searchController.text = query;
    _onSearchSubmitted(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _SearchBar(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchSubmitted,
          onClear: () {
            _searchController.clear();
            context.read<ProductProvider>().clearSearchResults();
            setState(() => _showResults = false);
          },
        ),
      ),
      body: _showResults
          ? _SearchResults()
          : _SearchPlaceholder(
              recentSearches: _recentSearches,
              onRecentSearchTap: _onRecentSearchTap,
              onRemoveRecentSearch: _removeRecentSearch,
              onClearRecentSearches: _clearRecentSearches,
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          borderSide: BorderSide.none,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
      ),
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onRecentSearchTap;
  final ValueChanged<String> onRemoveRecentSearch;
  final VoidCallback onClearRecentSearches;

  const _SearchPlaceholder({
    required this.recentSearches,
    required this.onRecentSearchTap,
    required this.onRemoveRecentSearch,
    required this.onClearRecentSearches,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      children: [
        // Recent Searches
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: onClearRecentSearches,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSm),
          ...recentSearches.map((search) => ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onRemoveRecentSearch(search),
                ),
                onTap: () => onRecentSearchTap(search),
              )),
          const Divider(height: AppConstants.spacingLg),
        ],

        // Popular Categories
        Text(
          'Popular Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Wrap(
          spacing: AppConstants.spacingSm,
          runSpacing: AppConstants.spacingSm,
          children: [
            _CategoryChip(label: 'Electronics', icon: Icons.devices),
            _CategoryChip(label: 'Fashion', icon: Icons.checkroom),
            _CategoryChip(label: 'Home', icon: Icons.home),
            _CategoryChip(label: 'Sports', icon: Icons.sports_basketball),
            _CategoryChip(label: 'Books', icon: Icons.menu_book),
            _CategoryChip(label: 'Beauty', icon: Icons.spa),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CategoryChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => context.push('/products?category=${label.toLowerCase()}'),
    );
  }
}

class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: AppConstants.spacingMd),
                Text(
                  'No products found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.spacingSm),
                const Text('Try a different search term'),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: AppConstants.spacingMd,
            mainAxisSpacing: AppConstants.spacingMd,
          ),
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: provider.searchResults[index],
              onTap: () => context.push('/search/product/${provider.searchResults[index].id}'),
            );
          },
        );
      },
    );
  }
}
