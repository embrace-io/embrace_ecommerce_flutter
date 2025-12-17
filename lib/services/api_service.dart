import 'dart:async';
import '../models/models.dart';
import 'embrace_service.dart';
import 'mock_data_service.dart';

/// ApiService - Central API orchestration service
///
/// Handles all API calls with Embrace telemetry integration.
/// Currently uses MockDataService but can be switched to real API.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  static ApiService get shared => _instance;

  ApiService._internal();

  final EmbraceService _embrace = EmbraceService.shared;
  final MockDataService _mockData = MockDataService.shared;

  // Toggle for mock vs real API
  bool useMockData = true;

  // MARK: - Products

  Future<List<Product>> fetchProducts({
    String? category,
    int limit = 20,
    int offset = 0,
  }) async {
    final span = await _embrace.startSpan('fetch_products');
    await span?.addAttribute('category', category ?? 'all');
    await span?.addAttribute('limit', limit.toString());
    await span?.addAttribute('offset', offset.toString());

    try {
      final products = await _mockData.withSimulatedDelay(() {
        return _mockData.getProducts(
          category: category,
          limit: limit,
          offset: offset,
        );
      });

      await span?.addAttribute('result_count', products.length.toString());
      await span?.stop();

      return products;
    } catch (e) {
      await _embrace.logError('Failed to fetch products', properties: {
        'error': e.toString(),
        'category': category ?? 'all',
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<Product?> fetchProduct(String id) async {
    final span = await _embrace.startSpan('fetch_product');
    await span?.addAttribute('product_id', id);

    try {
      final product = await _mockData.withSimulatedDelay(() {
        return _mockData.getProduct(id);
      });

      await span?.addAttribute('found', (product != null).toString());
      await span?.stop();

      return product;
    } catch (e) {
      await _embrace.logError('Failed to fetch product', properties: {
        'error': e.toString(),
        'product_id': id,
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<List<Product>> searchProducts(
    String query, {
    String? category,
    int limit = 20,
  }) async {
    final span = await _embrace.startSpan('search_products');
    await span?.addAttribute('query', query);
    await span?.addAttribute('category', category ?? 'all');

    try {
      final products = await _mockData.withSimulatedDelay(() {
        var results = _mockData.searchProducts(query);
        if (category != null) {
          results = results.where((p) => p.category == category).toList();
        }
        return results.take(limit).toList();
      });

      await span?.addAttribute('result_count', products.length.toString());
      await span?.stop();

      // Track search for analytics
      await _embrace.trackSearchPerformed(
        query,
        products.length,
        filters: category != null ? {'category': category} : null,
      );

      return products;
    } catch (e) {
      await _embrace.logError('Failed to search products', properties: {
        'error': e.toString(),
        'query': query,
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    final span = await _embrace.startSpan('fetch_featured_products');

    try {
      final products = await _mockData.withSimulatedDelay(() {
        return _mockData.getFeaturedProducts();
      });

      await span?.addAttribute('count', products.length.toString());
      await span?.stop();

      return products;
    } catch (e) {
      await _embrace.logError('Failed to fetch featured products', properties: {
        'error': e.toString(),
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<List<Product>> fetchNewArrivals() async {
    final span = await _embrace.startSpan('fetch_new_arrivals');

    try {
      final products = await _mockData.withSimulatedDelay(() {
        return _mockData.getNewArrivals();
      });

      await span?.addAttribute('count', products.length.toString());
      await span?.stop();

      return products;
    } catch (e) {
      await _embrace.logError('Failed to fetch new arrivals', properties: {
        'error': e.toString(),
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<List<Product>> fetchDailyDeals() async {
    final span = await _embrace.startSpan('fetch_daily_deals');

    try {
      final products = await _mockData.withSimulatedDelay(() {
        return _mockData.getDailyDeals();
      });

      await span?.addAttribute('count', products.length.toString());
      await span?.stop();

      return products;
    } catch (e) {
      await _embrace.logError('Failed to fetch daily deals', properties: {
        'error': e.toString(),
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<List<Product>> fetchRelatedProducts(
    String productId, {
    int limit = 4,
  }) async {
    final span = await _embrace.startSpan('fetch_related_products');
    await span?.addAttribute('product_id', productId);

    try {
      final products = await _mockData.withSimulatedDelay(() {
        return _mockData.getRelatedProducts(productId, limit: limit);
      });

      await span?.addAttribute('count', products.length.toString());
      await span?.stop();

      return products;
    } catch (e) {
      await _embrace.logError('Failed to fetch related products', properties: {
        'error': e.toString(),
        'product_id': productId,
      });
      await span?.stop();
      rethrow;
    }
  }

  // MARK: - Categories

  Future<List<Category>> fetchCategories() async {
    final span = await _embrace.startSpan('fetch_categories');

    try {
      final categories = await _mockData.withSimulatedDelay(() {
        return _mockData.getCategories();
      });

      await span?.addAttribute('count', categories.length.toString());
      await span?.stop();

      return categories;
    } catch (e) {
      await _embrace.logError('Failed to fetch categories', properties: {
        'error': e.toString(),
      });
      await span?.stop();
      rethrow;
    }
  }

  // MARK: - Orders

  Future<Order> createOrder({
    required List<CartItem> items,
    required Address shippingAddress,
    Address? billingAddress,
    required PaymentMethod paymentMethod,
    required ShippingMethod shippingMethod,
    String? userId,
  }) async {
    final span = await _embrace.startSpan('create_order');

    try {
      // Calculate totals
      final subtotal = items.fold(0.0, (sum, item) => sum + item.totalPrice);
      final tax = subtotal * 0.08875; // NY tax rate
      final shipping = shippingMethod.cost;
      final total = subtotal + tax + shipping;

      // Simulate order creation
      await Future.delayed(const Duration(milliseconds: 1500));

      final order = Order(
        id: 'order_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        items: items.map((item) => OrderItem(
          id: 'item_${item.id}',
          productId: item.productId,
          productName: item.product.name,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          selectedVariants: item.selectedVariants,
          imageUrl: item.product.primaryImageUrl,
        )).toList(),
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        paymentMethod: paymentMethod,
        shippingMethod: shippingMethod,
        status: OrderStatus.processing,
        subtotal: subtotal,
        tax: tax,
        shipping: shipping,
        total: total,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(
          Duration(days: shippingMethod.estimatedDays),
        ),
        trackingNumber: 'TRK${DateTime.now().millisecondsSinceEpoch}',
      );

      await span?.addAttribute('order_id', order.id);
      await span?.addAttribute('total', total.toString());
      await span?.addAttribute('item_count', items.length.toString());
      await span?.stop();

      await _embrace.addBreadcrumb('ORDER_DETAILS_API_COMPLETED');

      return order;
    } catch (e) {
      await _embrace.logError('Failed to create order', properties: {
        'error': e.toString(),
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<List<Order>> fetchOrders(String userId) async {
    final span = await _embrace.startSpan('fetch_orders');
    await span?.addAttribute('user_id', userId);

    try {
      // Simulate fetching orders - return empty for mock
      await Future.delayed(const Duration(milliseconds: 500));

      await span?.stop();
      return [];
    } catch (e) {
      await _embrace.logError('Failed to fetch orders', properties: {
        'error': e.toString(),
        'user_id': userId,
      });
      await span?.stop();
      rethrow;
    }
  }

  // MARK: - Payment

  Future<Map<String, dynamic>> createPaymentIntent(
    double amount, {
    String currency = 'usd',
  }) async {
    final span = await _embrace.startSpan('create_payment_intent');
    await span?.addAttribute('amount', amount.toString());
    await span?.addAttribute('currency', currency);

    try {
      // Simulate payment intent creation
      await Future.delayed(const Duration(milliseconds: 800));

      final paymentIntent = {
        'id': 'pi_${DateTime.now().millisecondsSinceEpoch}',
        'client_secret': 'cs_test_${DateTime.now().millisecondsSinceEpoch}',
        'amount': (amount * 100).round(), // Convert to cents
        'currency': currency,
        'status': 'requires_payment_method',
      };

      await span?.stop();
      return paymentIntent;
    } catch (e) {
      await _embrace.logError('Failed to create payment intent', properties: {
        'error': e.toString(),
        'amount': amount.toString(),
      });
      await span?.stop();
      rethrow;
    }
  }

  Future<bool> confirmPayment(
    String paymentIntentId,
    String paymentMethodId,
  ) async {
    final span = await _embrace.startSpan('confirm_payment');
    await span?.addAttribute('payment_intent_id', paymentIntentId);

    try {
      await _embrace.addBreadcrumb('STRIPE_PAYMENT_PROCESSING_STARTED');

      // Simulate payment confirmation
      await Future.delayed(const Duration(milliseconds: 1200));

      // 95% success rate for demo
      final success = DateTime.now().millisecond % 100 < 95;

      if (success) {
        await _embrace.addBreadcrumb('STRIPE_PAYMENT_PROCESSING_SUCCESS');
      } else {
        await _embrace.addBreadcrumb('STRIPE_PAYMENT_PROCESSING_FAILED');
      }

      await span?.addAttribute('success', success.toString());
      await span?.stop();

      return success;
    } catch (e) {
      await _embrace.logError('Failed to confirm payment', properties: {
        'error': e.toString(),
        'payment_intent_id': paymentIntentId,
      });
      await _embrace.addBreadcrumb('STRIPE_PAYMENT_PROCESSING_FAILED');
      await span?.stop();
      rethrow;
    }
  }
}
