import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:embrace_ecommerce_flutter/main.dart' as app;

import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cart Flow Tests', () {
    testWidgets('User can view empty cart', (tester) async {
      TestUtils.logStep('Starting empty cart test - RUN_SOURCE: ${TestUtils.runSource}');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Cart
      await TestUtils.tapNavBarItem(tester, 'Cart');
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Navigated to Cart');

      // Look for empty cart message or cart content
      final emptyCartText = find.textContaining('empty');
      final cartItems = find.byType(Dismissible);

      if (emptyCartText.evaluate().isNotEmpty) {
        TestUtils.logStep('Empty cart message displayed');
      } else if (cartItems.evaluate().isNotEmpty) {
        TestUtils.logStep('Cart has ${cartItems.evaluate().length} items');
      }

      await TestUtils.pauseForTelemetry(tester);
      TestUtils.logStep('Empty cart test completed');
    });

    testWidgets('User can add product to cart', (tester) async {
      TestUtils.logStep('Starting add to cart test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap a product
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);

        TestUtils.logStep('Opened product detail');

        // Look for Add to Cart button
        final addToCartButton = find.textContaining('Add to Cart');
        final addButton = find.byIcon(Icons.add_shopping_cart);

        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Tapped Add to Cart');
        } else if (addButton.evaluate().isNotEmpty) {
          await tester.tap(addButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Tapped add icon');
        }

        // Navigate to Cart to verify
        await TestUtils.tapNavBarItem(tester, 'Cart');
        await TestUtils.pauseForTelemetry(tester);

        TestUtils.logStep('Navigated to Cart after adding item');
      }

      TestUtils.logStep('Add to cart test completed');
    });

    testWidgets('User can modify cart quantity', (tester) async {
      TestUtils.logStep('Starting cart quantity test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First add a product
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
        }

        // Navigate to Cart
        await TestUtils.tapNavBarItem(tester, 'Cart');
        await tester.pumpAndSettle();

        // Look for quantity controls
        final incrementButton = find.byIcon(Icons.add);
        final decrementButton = find.byIcon(Icons.remove);

        if (incrementButton.evaluate().isNotEmpty) {
          await tester.tap(incrementButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Incremented quantity');
        }

        if (decrementButton.evaluate().isNotEmpty) {
          await tester.tap(decrementButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Decremented quantity');
        }
      }

      TestUtils.logStep('Cart quantity test completed');
    });

    testWidgets('User can remove item from cart', (tester) async {
      TestUtils.logStep('Starting remove from cart test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First add a product
      final productCards = find.byType(Card);
      if (productCards.evaluate().isNotEmpty) {
        await tester.tap(productCards.first);
        await tester.pumpAndSettle();

        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          await tester.tap(addToCartButton.first);
          await tester.pumpAndSettle();
        }

        // Navigate to Cart
        await TestUtils.tapNavBarItem(tester, 'Cart');
        await tester.pumpAndSettle();

        // Look for delete/remove option
        final deleteButton = find.byIcon(Icons.delete);
        final removeButton = find.byIcon(Icons.remove_circle);
        final dismissibleItems = find.byType(Dismissible);

        if (deleteButton.evaluate().isNotEmpty) {
          await tester.tap(deleteButton.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Tapped delete button');
        } else if (dismissibleItems.evaluate().isNotEmpty) {
          // Swipe to dismiss
          await tester.drag(dismissibleItems.first, const Offset(-300, 0));
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Swiped to remove item');
        }
      }

      TestUtils.logStep('Remove from cart test completed');
    });
  });
}
