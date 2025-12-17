import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

/// CartProvider - Manages shopping cart state
///
/// Provides cart functionality with persistence and Embrace telemetry.
class CartProvider extends ChangeNotifier {
  final EmbraceService _embrace = EmbraceService.shared;
  final Uuid _uuid = const Uuid();

  static const String _cartKey = 'shopping_cart';

  Cart _cart = Cart.empty();

  Cart get cart => _cart;
  List<CartItem> get items => _cart.items;
  int get totalItems => _cart.totalItems;
  double get subtotal => _cart.subtotal;
  String get formattedSubtotal => _cart.formattedSubtotal;
  bool get isEmpty => _cart.isEmpty;

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      if (cartJson != null) {
        _cart = Cart.fromJson(jsonDecode(cartJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, jsonEncode(_cart.toJson()));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    Map<String, String>? selectedVariants,
  }) async {
    // Check if item already exists in cart
    final existingIndex = _cart.items.indexWhere(
      (item) => item.productId == product.id,
    );

    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      // Update quantity of existing item
      updatedItems = List.from(_cart.items);
      final existingItem = updatedItems[existingIndex];
      updatedItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Add new item
      final newItem = CartItem(
        id: _uuid.v4(),
        productId: product.id,
        quantity: quantity,
        selectedVariants: selectedVariants ?? {},
        addedAt: DateTime.now(),
        unitPrice: product.price,
        product: product,
      );
      updatedItems = [..._cart.items, newItem];
    }

    _cart = _cart.copyWith(items: updatedItems);
    await _saveCart();
    notifyListeners();

    // Track with Embrace
    await _embrace.trackAddToCart(
      product.id,
      quantity,
      product.price * quantity,
    );
  }

  Future<void> removeFromCart(String itemId) async {
    final item = _cart.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );

    final updatedItems = _cart.items.where((i) => i.id != itemId).toList();
    _cart = _cart.copyWith(items: updatedItems);
    await _saveCart();
    notifyListeners();

    // Track with Embrace
    await _embrace.trackRemoveFromCart(item.productId, item.quantity);
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(itemId);
      return;
    }

    final updatedItems = _cart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    _cart = _cart.copyWith(items: updatedItems);
    await _saveCart();
    notifyListeners();

    await _embrace.logInfo('Cart quantity updated', properties: {
      'item_id': itemId,
      'quantity': quantity.toString(),
    });
  }

  Future<void> clearCart() async {
    _cart = Cart.empty();
    await _saveCart();
    notifyListeners();

    await _embrace.addBreadcrumb('Cart cleared');
  }

  Future<void> trackCartViewed() async {
    await _embrace.trackCartViewed(totalItems, subtotal);
  }

  CartItem? getItem(String itemId) {
    try {
      return _cart.items.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  bool containsProduct(String productId) {
    return _cart.items.any((item) => item.productId == productId);
  }
}
