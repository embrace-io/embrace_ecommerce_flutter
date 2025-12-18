import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:embrace_ecommerce_flutter/main.dart' as app;

import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Checkout Flow Tests', () {
    testWidgets('User can initiate checkout from cart', (tester) async {
      TestUtils.logStep('Starting checkout initiation test - RUN_SOURCE: ${TestUtils.runSource}');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First add a product to cart
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Added product to cart');
        }

        // Navigate to Cart
        await TestUtils.tapNavBarItem(tester, 'Cart');
        await tester.pumpAndSettle();

        // Look for checkout button
        final checkoutButton = find.textContaining('Checkout');
        final proceedButton = find.textContaining('Proceed');

        if (checkoutButton.evaluate().isNotEmpty) {
          await tester.tap(checkoutButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Initiated checkout');
        } else if (proceedButton.evaluate().isNotEmpty) {
          await tester.tap(proceedButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Proceeded to checkout');
        }
      }

      TestUtils.logStep('Checkout initiation test completed');
    });

    testWidgets('User can view checkout screen elements', (tester) async {
      TestUtils.logStep('Starting checkout screen test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Add product and go to checkout
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
        }

        await TestUtils.tapNavBarItem(tester, 'Cart');
        await tester.pumpAndSettle();

        final checkoutButton = find.textContaining('Checkout');
        if (checkoutButton.evaluate().isNotEmpty) {
          await tester.tap(checkoutButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);

          // Look for checkout elements
          final shippingSection = find.textContaining('Shipping');
          final paymentSection = find.textContaining('Payment');
          final totalSection = find.textContaining('Total');
          final placeOrderButton = find.textContaining('Place Order');

          if (shippingSection.evaluate().isNotEmpty) {
            TestUtils.logStep('Shipping section found');
          }
          if (paymentSection.evaluate().isNotEmpty) {
            TestUtils.logStep('Payment section found');
          }
          if (totalSection.evaluate().isNotEmpty) {
            TestUtils.logStep('Total section found');
          }
          if (placeOrderButton.evaluate().isNotEmpty) {
            TestUtils.logStep('Place Order button found');
          }

          await TestUtils.pauseForTelemetry(tester);
        }
      }

      TestUtils.logStep('Checkout screen test completed');
    });

    testWidgets('User can select shipping address', (tester) async {
      TestUtils.logStep('Starting shipping address test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through to checkout
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
        }

        await TestUtils.tapNavBarItem(tester, 'Cart');
        await tester.pumpAndSettle();

        final checkoutButton = find.textContaining('Checkout');
        if (checkoutButton.evaluate().isNotEmpty) {
          await tester.tap(checkoutButton.first);
          await tester.pumpAndSettle();

          // Look for address selection
          final addressSection = find.textContaining('Address');
          final shippingSection = find.textContaining('Shipping');
          final editButton = find.byIcon(Icons.edit);
          final changeButton = find.textContaining('Change');

          if (addressSection.evaluate().isNotEmpty || shippingSection.evaluate().isNotEmpty) {
            TestUtils.logStep('Address/Shipping section found');

            if (editButton.evaluate().isNotEmpty) {
              await tester.tap(editButton.first);
              await tester.pumpAndSettle();
              await TestUtils.pauseForTelemetry(tester);
              TestUtils.logStep('Opened address edit');

              // Close
              final closeButton = find.byIcon(Icons.close);
              final backButton = find.byIcon(Icons.arrow_back);
              if (closeButton.evaluate().isNotEmpty) {
                await tester.tap(closeButton.first);
                await tester.pumpAndSettle();
              } else if (backButton.evaluate().isNotEmpty) {
                await tester.tap(backButton.first);
                await tester.pumpAndSettle();
              }
            }
          }
        }
      }

      TestUtils.logStep('Shipping address test completed');
    });

    testWidgets('User can select payment method', (tester) async {
      TestUtils.logStep('Starting payment method test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate through to checkout
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
        }

        await TestUtils.tapNavBarItem(tester, 'Cart');
        await tester.pumpAndSettle();

        final checkoutButton = find.textContaining('Checkout');
        if (checkoutButton.evaluate().isNotEmpty) {
          await tester.tap(checkoutButton.first);
          await tester.pumpAndSettle();

          // Look for payment selection
          final paymentSection = find.textContaining('Payment');
          final cardOption = find.textContaining('Card');
          final creditCard = find.byIcon(Icons.credit_card);

          if (paymentSection.evaluate().isNotEmpty) {
            TestUtils.logStep('Payment section found');
          }

          if (cardOption.evaluate().isNotEmpty) {
            await tester.tap(cardOption.first);
            await tester.pumpAndSettle();
            await TestUtils.pauseForTelemetry(tester);
            TestUtils.logStep('Selected card payment option');
          }

          if (creditCard.evaluate().isNotEmpty) {
            TestUtils.logStep('Credit card icon found');
          }
        }
      }

      TestUtils.logStep('Payment method test completed');
    });
  });
}
