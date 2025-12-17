import 'package:flutter/foundation.dart' hide Category;
import '../models/models.dart';
import '../services/services.dart';

enum ProductLoadingState { initial, loading, loaded, error }

/// ProductProvider - Manages product catalog state
///
/// Handles product fetching, searching, and category management
/// with Embrace telemetry integration.
class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.shared;
  final EmbraceService _embrace = EmbraceService.shared;

  ProductLoadingState _state = ProductLoadingState.initial;
  List<Product> _featuredProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _dailyDeals = [];
  List<Category> _categories = [];
  List<Product> _searchResults = [];
  List<Product> _categoryProducts = [];
  String? _errorMessage;

  ProductLoadingState get state => _state;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get newArrivals => _newArrivals;
  List<Product> get dailyDeals => _dailyDeals;
  List<Category> get categories => _categories;
  List<Product> get searchResults => _searchResults;
  List<Product> get categoryProducts => _categoryProducts;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ProductLoadingState.loading;
  bool get hasError => _state == ProductLoadingState.error;

  ProductProvider() {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    _state = ProductLoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load all initial data in parallel
      final results = await Future.wait([
        _apiService.fetchFeaturedProducts(),
        _apiService.fetchNewArrivals(),
        _apiService.fetchDailyDeals(),
        _apiService.fetchCategories(),
      ]);

      _featuredProducts = results[0] as List<Product>;
      _newArrivals = results[1] as List<Product>;
      _dailyDeals = results[2] as List<Product>;
      _categories = results[3] as List<Category>;

      _state = ProductLoadingState.loaded;

      await _embrace.logInfo('Initial product data loaded', properties: {
        'featured_count': _featuredProducts.length.toString(),
        'new_arrivals_count': _newArrivals.length.toString(),
        'daily_deals_count': _dailyDeals.length.toString(),
        'categories_count': _categories.length.toString(),
      });
    } catch (e) {
      _errorMessage = 'Failed to load products';
      _state = ProductLoadingState.error;
      await _embrace.logError('Failed to load initial data', properties: {
        'error': e.toString(),
      });
    }

    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }

  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _state = ProductLoadingState.loading;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchProducts(query);
      _state = ProductLoadingState.loaded;
    } catch (e) {
      _errorMessage = 'Search failed';
      _state = ProductLoadingState.error;
    }

    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  Future<void> loadProductsByCategory(String category) async {
    _state = ProductLoadingState.loading;
    notifyListeners();

    try {
      _categoryProducts = await _apiService.fetchProducts(category: category);
      _state = ProductLoadingState.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load category products';
      _state = ProductLoadingState.error;
    }

    notifyListeners();
  }

  Future<Product?> getProduct(String productId) async {
    return await _apiService.fetchProduct(productId);
  }

  Future<List<Product>> getRelatedProducts(String productId) async {
    return await _apiService.fetchRelatedProducts(productId);
  }

  void clearError() {
    _errorMessage = null;
    _state = ProductLoadingState.loaded;
    notifyListeners();
  }
}
