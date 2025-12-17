import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/main_tab_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/address_book_screen.dart';
import '../screens/profile/payment_methods_screen.dart';
import '../screens/profile/order_history_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/product/product_list_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/auth/email_auth_screen.dart';
import '../services/services.dart';

/// App router configuration using go_router
class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final EmbraceService _embrace = EmbraceService.shared;

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainTabScreen(child: child);
        },
        routes: [
          // Home tab
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) {
              _trackScreenView('Home');
              return const NoTransitionPage(child: HomeScreen());
            },
            routes: [
              // Product detail from home
              GoRoute(
                path: 'product/:id',
                name: 'home-product',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  _trackScreenView('ProductDetail');
                  return ProductDetailScreen(productId: productId);
                },
              ),
              // Product list by category
              GoRoute(
                path: 'products',
                name: 'products',
                builder: (context, state) {
                  final category = state.uri.queryParameters['category'];
                  _trackScreenView('ProductList');
                  return ProductListScreen(category: category);
                },
              ),
            ],
          ),
          // Search tab
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) {
              _trackScreenView('Search');
              return const NoTransitionPage(child: SearchScreen());
            },
            routes: [
              // Product detail from search
              GoRoute(
                path: 'product/:id',
                name: 'search-product',
                builder: (context, state) {
                  final productId = state.pathParameters['id']!;
                  _trackScreenView('ProductDetail');
                  return ProductDetailScreen(productId: productId);
                },
              ),
            ],
          ),
          // Cart tab
          GoRoute(
            path: '/cart',
            name: 'cart',
            pageBuilder: (context, state) {
              _trackScreenView('Cart');
              return const NoTransitionPage(child: CartScreen());
            },
          ),
          // Profile tab
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) {
              _trackScreenView('Profile');
              return const NoTransitionPage(child: ProfileScreen());
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) {
                  _trackScreenView('EditProfile');
                  return const EditProfileScreen();
                },
              ),
              GoRoute(
                path: 'addresses',
                name: 'address-book',
                builder: (context, state) {
                  _trackScreenView('AddressBook');
                  return const AddressBookScreen();
                },
              ),
              GoRoute(
                path: 'payment-methods',
                name: 'payment-methods',
                builder: (context, state) {
                  _trackScreenView('PaymentMethods');
                  return const PaymentMethodsScreen();
                },
              ),
              GoRoute(
                path: 'orders',
                name: 'order-history',
                builder: (context, state) {
                  _trackScreenView('OrderHistory');
                  return const OrderHistoryScreen();
                },
              ),
            ],
          ),
        ],
      ),
      // Checkout flow (outside shell - full screen)
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          _trackScreenView('Checkout');
          return const CheckoutScreen();
        },
      ),
      // Auth flow (outside shell - full screen)
      GoRoute(
        path: '/auth',
        name: 'auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          _trackScreenView('Authentication');
          return const AuthScreen();
        },
        routes: [
          GoRoute(
            path: 'email',
            name: 'email-auth',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) {
              final isSignUp = state.uri.queryParameters['signup'] == 'true';
              _trackScreenView(isSignUp ? 'EmailSignUp' : 'EmailSignIn');
              return EmailAuthScreen(isSignUp: isSignUp);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page not found: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    },
  );

  static void _trackScreenView(String screenName) {
    _embrace.trackScreenView(screenName);
  }
}
