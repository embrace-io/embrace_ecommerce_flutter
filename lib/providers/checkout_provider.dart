import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

enum CheckoutStep { cartReview, shipping, payment, confirmation }

enum CheckoutState { idle, loading, success, error }

/// CheckoutProvider - Manages multi-step checkout flow
///
/// Coordinates the checkout process with Embrace telemetry breadcrumbs
/// for user flow tracking.
class CheckoutProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService.shared;
  final EmbraceService _embrace = EmbraceService.shared;

  CheckoutStep _currentStep = CheckoutStep.cartReview;
  CheckoutState _state = CheckoutState.idle;
  Address? _shippingAddress;
  Address? _billingAddress;
  PaymentMethod? _paymentMethod;
  ShippingMethod? _shippingMethod;
  Order? _completedOrder;
  String? _errorMessage;

  // Tax rate (NY)
  static const double _taxRate = 0.08875;

  CheckoutStep get currentStep => _currentStep;
  CheckoutState get state => _state;
  Address? get shippingAddress => _shippingAddress;
  Address? get billingAddress => _billingAddress;
  PaymentMethod? get paymentMethod => _paymentMethod;
  ShippingMethod? get shippingMethod => _shippingMethod;
  Order? get completedOrder => _completedOrder;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == CheckoutState.loading;

  int get currentStepIndex {
    switch (_currentStep) {
      case CheckoutStep.cartReview:
        return 0;
      case CheckoutStep.shipping:
        return 1;
      case CheckoutStep.payment:
        return 2;
      case CheckoutStep.confirmation:
        return 3;
    }
  }

  List<ShippingMethod> get availableShippingMethods => ShippingMethods.all;

  CheckoutProvider() {
    _embrace.addBreadcrumb('CHECKOUT_STARTED');
  }

  // MARK: - Step Navigation

  bool canProceed() {
    switch (_currentStep) {
      case CheckoutStep.cartReview:
        return true; // Cart validation handled by CartProvider
      case CheckoutStep.shipping:
        return _shippingAddress != null && _shippingMethod != null;
      case CheckoutStep.payment:
        return _paymentMethod != null;
      case CheckoutStep.confirmation:
        return false; // Final step
    }
  }

  Future<void> goToNextStep() async {
    if (!canProceed()) return;

    switch (_currentStep) {
      case CheckoutStep.cartReview:
        _currentStep = CheckoutStep.shipping;
        break;
      case CheckoutStep.shipping:
        await _embrace.addBreadcrumb('SHIPPING_INFORMATION_COMPLETED');
        await _embrace.addBreadcrumb('CHECKOUT_SHIPPING_COMPLETED');
        _currentStep = CheckoutStep.payment;
        break;
      case CheckoutStep.payment:
        await _embrace.addBreadcrumb('CHECKOUT_PAYMENT_COMPLETED');
        _currentStep = CheckoutStep.confirmation;
        break;
      case CheckoutStep.confirmation:
        break;
    }

    notifyListeners();
  }

  void goToPreviousStep() {
    switch (_currentStep) {
      case CheckoutStep.cartReview:
        break; // Can't go back from first step
      case CheckoutStep.shipping:
        _currentStep = CheckoutStep.cartReview;
        break;
      case CheckoutStep.payment:
        _currentStep = CheckoutStep.shipping;
        break;
      case CheckoutStep.confirmation:
        _currentStep = CheckoutStep.payment;
        break;
    }

    notifyListeners();
  }

  void goToStep(CheckoutStep step) {
    _currentStep = step;
    notifyListeners();
  }

  // MARK: - Shipping

  void setShippingAddress(Address address) {
    _shippingAddress = address;
    notifyListeners();
  }

  void setBillingAddress(Address? address) {
    _billingAddress = address;
    notifyListeners();
  }

  void setShippingMethod(ShippingMethod method) {
    _shippingMethod = method;
    notifyListeners();
  }

  // MARK: - Payment

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  // MARK: - Order Totals

  double calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double calculateTax(double subtotal) {
    return subtotal * _taxRate;
  }

  double calculateTotal(List<CartItem> items) {
    final subtotal = calculateSubtotal(items);
    final tax = calculateTax(subtotal);
    final shipping = _shippingMethod?.cost ?? 0;
    return subtotal + tax + shipping;
  }

  // MARK: - Place Order

  Future<bool> placeOrder(List<CartItem> items, {String? userId}) async {
    if (_shippingAddress == null ||
        _shippingMethod == null ||
        _paymentMethod == null) {
      _errorMessage = 'Missing required checkout information';
      _state = CheckoutState.error;
      notifyListeners();
      return false;
    }

    _state = CheckoutState.loading;
    _errorMessage = null;
    notifyListeners();

    final total = calculateTotal(items);

    try {
      await _embrace.addBreadcrumb('PLACE_ORDER_INITIATED');
      await _embrace.trackPurchaseAttempt(
        'pending_${DateTime.now().millisecondsSinceEpoch}',
        total,
        items.length,
      );

      // Create payment intent
      final paymentIntent = await _apiService.createPaymentIntent(total);

      // Confirm payment
      final paymentSuccess = await _apiService.confirmPayment(
        paymentIntent['id'],
        _paymentMethod!.id,
      );

      if (!paymentSuccess) {
        throw Exception('Payment failed');
      }

      // Create order
      _completedOrder = await _apiService.createOrder(
        items: items,
        shippingAddress: _shippingAddress!,
        billingAddress: _billingAddress,
        paymentMethod: _paymentMethod!,
        shippingMethod: _shippingMethod!,
        userId: userId,
      );

      await _embrace.trackPurchaseSuccess(
        _completedOrder!.id,
        total,
        _paymentMethod!.displayName,
      );

      _state = CheckoutState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CheckoutState.error;

      await _embrace.trackPurchaseFailure(
        'failed_order',
        e.toString(),
        'order_creation_failed',
      );

      notifyListeners();
      return false;
    }
  }

  // MARK: - Reset

  void reset() {
    _currentStep = CheckoutStep.cartReview;
    _state = CheckoutState.idle;
    _shippingAddress = null;
    _billingAddress = null;
    _paymentMethod = null;
    _shippingMethod = null;
    _completedOrder = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _state = CheckoutState.idle;
    notifyListeners();
  }
}
