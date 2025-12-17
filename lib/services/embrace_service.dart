import 'package:embrace/embrace.dart';
import 'package:embrace/embrace_api.dart';
import 'package:embrace_platform_interface/last_run_end_state.dart';

/// EmbraceService - Telemetry wrapper mirroring iOS EmbraceService
///
/// Provides a unified interface for all Embrace SDK telemetry operations
/// including logging, spans, breadcrumbs, session properties, and
/// e-commerce specific tracking.
class EmbraceService {
  static final EmbraceService _instance = EmbraceService._internal();
  static EmbraceService get shared => _instance;

  EmbraceService._internal();

  final Embrace _embrace = Embrace.instance;

  // MARK: - Logging Methods

  Future<void> logInfo(String message, {Map<String, String>? properties}) async {
    _embrace.logInfo(message, properties: properties);
  }

  Future<void> logWarning(String message, {Map<String, String>? properties}) async {
    _embrace.logWarning(message, properties: properties);
  }

  Future<void> logError(String message, {Map<String, String>? properties}) async {
    _embrace.logError(message, properties: properties);
  }

  // MARK: - Custom Spans

  Future<EmbraceSpan?> startSpan(String name) async {
    return await _embrace.startSpan(name);
  }

  Future<void> recordCompletedSpan(
    String name, {
    DateTime? startTime,
    DateTime? endTime,
    Map<String, String>? attributes,
  }) async {
    final span = await _embrace.startSpan(name);
    if (span != null) {
      if (attributes != null) {
        for (final entry in attributes.entries) {
          await span.addAttribute(entry.key, entry.value);
        }
      }
      await span.stop();
    }
  }

  // MARK: - Breadcrumbs

  Future<void> addBreadcrumb(String message) async {
    _embrace.addBreadcrumb(message);
  }

  // MARK: - Session Properties

  Future<void> addSessionProperty(
    String key,
    String value, {
    bool permanent = false,
  }) async {
    _embrace.addSessionProperty(key, value, permanent: permanent);
  }

  Future<void> removeSessionProperty(String key) async {
    _embrace.removeSessionProperty(key);
  }

  // MARK: - User Identification

  Future<void> setUserIdentifier(String userId) async {
    _embrace.setUserIdentifier(userId);
  }

  Future<void> setUserPersona(String persona) async {
    _embrace.addUserPersona(persona);
  }

  Future<void> clearUserPersona(String persona) async {
    _embrace.clearUserPersona(persona);
  }

  // MARK: - User Journey Tracking

  Future<void> trackUserAction(
    String action,
    String screen, {
    Map<String, String>? properties,
  }) async {
    final breadcrumbMessage = '$action on $screen';
    await addBreadcrumb(breadcrumbMessage);

    final logProperties = <String, String>{
      'user_action': action,
      'screen': screen,
      ...?properties,
    };

    await logInfo('User action: $breadcrumbMessage', properties: logProperties);
  }

  Future<void> trackScreenView(
    String screenName, {
    Map<String, String>? properties,
  }) async {
    await addBreadcrumb('Viewed $screenName');

    final logProperties = <String, String>{
      'screen_name': screenName,
      ...?properties,
    };

    await logInfo('Screen view: $screenName', properties: logProperties);
  }

  // MARK: - E-commerce Specific Tracking

  Future<void> trackProductView(
    String productId,
    String productName, {
    String? category,
    double? price,
  }) async {
    final span = await startSpan('product_view');

    await span?.addAttribute('product.id', productId);
    await span?.addAttribute('product.name', productName);
    if (category != null) {
      await span?.addAttribute('product.category', category);
    }
    if (price != null) {
      await span?.addAttribute('product.price', price.toString());
    }

    await trackUserAction('product_view', 'product_detail', properties: {
      'product_id': productId,
      'product_name': productName,
    });

    await span?.stop();
  }

  Future<void> trackAddToCart(
    String productId,
    int quantity,
    double price,
  ) async {
    final span = await startSpan('add_to_cart');

    await span?.addAttribute('product.id', productId);
    await span?.addAttribute('cart.quantity', quantity.toString());
    await span?.addAttribute('cart.item_value', price.toString());

    await trackUserAction('add_to_cart', 'product_detail', properties: {
      'product_id': productId,
      'quantity': quantity.toString(),
      'value': price.toString(),
    });

    await span?.stop();
  }

  Future<void> trackRemoveFromCart(
    String productId,
    int quantity,
  ) async {
    final span = await startSpan('remove_from_cart');

    await span?.addAttribute('product.id', productId);
    await span?.addAttribute('cart.quantity', quantity.toString());

    await trackUserAction('remove_from_cart', 'cart', properties: {
      'product_id': productId,
      'quantity': quantity.toString(),
    });

    await span?.stop();
  }

  Future<void> trackCartViewed(int itemCount, double totalValue) async {
    await trackUserAction('cart_viewed', 'cart', properties: {
      'item_count': itemCount.toString(),
      'total_value': totalValue.toString(),
    });
  }

  Future<void> trackCheckoutStarted(int itemCount, double totalValue) async {
    await addBreadcrumb('CHECKOUT_STARTED');
    await trackUserAction('checkout_started', 'checkout', properties: {
      'item_count': itemCount.toString(),
      'total_value': totalValue.toString(),
    });
  }

  Future<void> trackCheckoutStepCompleted(
    String step,
    int itemCount,
    double totalValue,
  ) async {
    await addBreadcrumb('CHECKOUT_${step.toUpperCase()}_COMPLETED');
    await trackUserAction('checkout_step_completed', 'checkout', properties: {
      'step': step,
      'item_count': itemCount.toString(),
      'total_value': totalValue.toString(),
    });
  }

  Future<void> trackPurchaseAttempt(
    String orderId,
    double totalAmount,
    int itemCount,
  ) async {
    final span = await startSpan('purchase_attempt');

    await span?.addAttribute('order.id', orderId);
    await span?.addAttribute('order.total', totalAmount.toString());
    await span?.addAttribute('order.item_count', itemCount.toString());

    await addSessionProperty('current_order_id', orderId);

    await trackUserAction('purchase_attempt', 'checkout', properties: {
      'order_id': orderId,
      'total_amount': totalAmount.toString(),
      'item_count': itemCount.toString(),
    });

    await span?.stop();
  }

  Future<void> trackPurchaseSuccess(
    String orderId,
    double totalAmount,
    String paymentMethod,
  ) async {
    await recordCompletedSpan(
      'purchase_success',
      attributes: {
        'order.id': orderId,
        'order.total': totalAmount.toString(),
        'payment.method': paymentMethod,
      },
    );

    await removeSessionProperty('current_order_id');
    await addSessionProperty('last_successful_order', orderId, permanent: true);

    await logInfo('Purchase completed successfully', properties: {
      'order_id': orderId,
      'total_amount': totalAmount.toString(),
      'payment_method': paymentMethod,
    });

    await addBreadcrumb('ORDER_PLACED_SUCCESS');
  }

  Future<void> trackPurchaseFailure(
    String orderId,
    String errorMessage,
    String failureReason,
  ) async {
    await recordCompletedSpan(
      'purchase_failure',
      attributes: {
        'order.id': orderId,
        'error.message': errorMessage,
        'failure.reason': failureReason,
      },
    );

    await logError('Purchase failed', properties: {
      'order_id': orderId,
      'error_message': errorMessage,
      'failure_reason': failureReason,
    });

    await addBreadcrumb('ORDER_PLACED_FAILED');
  }

  // MARK: - Authentication Tracking

  Future<void> trackLoginAttempt(String method) async {
    final span = await startSpan('login_attempt');
    await span?.addAttribute('auth.method', method);
    await trackUserAction('login_attempt', 'authentication', properties: {
      'method': method,
    });
    await span?.stop();
  }

  Future<void> trackLoginSuccess(String userId, String method) async {
    await addSessionProperty('user_id', userId, permanent: true);
    await addSessionProperty('auth_method', method);
    await setUserIdentifier(userId);

    await logInfo('Login successful', properties: {
      'user_id': userId,
      'auth_method': method,
    });

    await addBreadcrumb('LOGIN_SUCCESS');
  }

  Future<void> trackLoginFailure(String method, String errorMessage) async {
    await recordCompletedSpan(
      'login_failure',
      attributes: {
        'auth.method': method,
        'error.message': errorMessage,
      },
    );

    await logError('Login failed', properties: {
      'auth_method': method,
      'error_message': errorMessage,
    });

    await addBreadcrumb('LOGIN_FAILED');
  }

  Future<void> trackLogout() async {
    await addBreadcrumb('USER_LOGGED_OUT');
    await logInfo('User logged out');
    _embrace.clearUserIdentifier();
  }

  // MARK: - Search Tracking

  Future<void> trackSearchPerformed(
    String query,
    int resultCount, {
    Map<String, String>? filters,
  }) async {
    final span = await startSpan('search_performed');

    await span?.addAttribute('search.query', query);
    await span?.addAttribute('search.result_count', resultCount.toString());

    if (filters != null) {
      for (final entry in filters.entries) {
        await span?.addAttribute('search.filter.${entry.key}', entry.value);
      }
    }

    final properties = <String, String>{
      'query': query,
      'result_count': resultCount.toString(),
      ...?filters,
    };

    await trackUserAction('search', 'search', properties: properties);

    await span?.stop();
  }

  // MARK: - Network Request Tracking

  Future<void> recordNetworkRequest(
    String url,
    String method, {
    DateTime? startTime,
    DateTime? endTime,
    int? statusCode,
    String? errorMessage,
    String? traceId,
  }) async {
    final span = await startSpan('network_request');

    await span?.addAttribute('http.url', url);
    await span?.addAttribute('http.method', method);

    if (statusCode != null) {
      await span?.addAttribute('http.status_code', statusCode.toString());
    }

    if (traceId != null) {
      await span?.addAttribute('http.trace_id', traceId);
    }

    if (errorMessage != null) {
      await span?.addAttribute('error.message', errorMessage);
    }

    await span?.stop();
  }

  // MARK: - Push Notification Tracking

  Future<void> recordPushNotification({
    String? title,
    String? body,
    String? topic,
    String? messageId,
  }) async {
    await addBreadcrumb('Push notification received');

    final attributes = <String, String>{};
    if (title != null && title.isNotEmpty) attributes['push.title'] = title;
    if (body != null && body.isNotEmpty) attributes['push.body'] = body;
    if (topic != null && topic.isNotEmpty) attributes['push.topic'] = topic;
    if (messageId != null && messageId.isNotEmpty) {
      attributes['push.message_id'] = messageId;
    }

    await logInfo('Push notification received', properties: attributes);
  }

  // MARK: - Crash Simulation (For Testing/Demo Purposes)

  /// Forces a crash in the app for testing Embrace crash reporting.
  Future<void> forceEmbraceCrash() async {
    final experiments = ['A', 'B', 'C', 'D'];
    final randomExperiment =
        experiments[(DateTime.now().millisecond % experiments.length)];

    await logError('Forcing a crash for testing', properties: {
      'experiment': randomExperiment,
      'trigger': 'manual_crash_button',
    });

    await addBreadcrumb('User triggered intentional crash');

    // Trigger a crash - in Flutter this can be done by throwing an error
    // that's not caught, or by using a native crash method
    throw Exception('Intentional crash triggered for Embrace testing');
  }

  // MARK: - Session Info

  Future<String?> getCurrentSessionId() async {
    return await _embrace.getCurrentSessionId();
  }

  Future<LastRunEndState?> getLastRunEndState() async {
    return await _embrace.getLastRunEndState();
  }
}
