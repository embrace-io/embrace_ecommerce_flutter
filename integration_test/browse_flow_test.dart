import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:embrace_ecommerce_flutter/main.dart' as app;

import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Browse Flow Tests', () {
    testWidgets('User can browse products on home screen', (tester) async {
      TestUtils.logStep('Starting browse flow test - RUN_SOURCE: ${TestUtils.runSource}');

      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      TestUtils.logStep('App launched successfully');

      // Verify home screen is displayed
      expect(find.text('Home'), findsWidgets);
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Home screen verified');

      // Look for product cards or list items
      await tester.pumpAndSettle();

      // Try to find product-related content
      final productFinder = find.byType(Card);
      if (productFinder.evaluate().isNotEmpty) {
        TestUtils.logStep('Found ${productFinder.evaluate().length} product cards');

        // Tap on first product
        await tester.tap(productFinder.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);

        TestUtils.logStep('Tapped on first product');

        // Go back to home
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Navigate to Search tab
      await TestUtils.tapNavBarItem(tester, 'Search');
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Navigated to Search screen');

      // Navigate back to Home
      await TestUtils.tapNavBarItem(tester, 'Home');
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Browse flow completed');
    });

    testWidgets('User can view product details', (tester) async {
      TestUtils.logStep('Starting product detail test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Look for any tappable product element
      final productCards = find.byType(Card);
      final listTiles = find.byType(ListTile);
      final inkWells = find.byType(InkWell);

      Finder? productFinder;
      if (productCards.evaluate().isNotEmpty) {
        productFinder = productCards;
      } else if (listTiles.evaluate().isNotEmpty) {
        productFinder = listTiles;
      } else if (inkWells.evaluate().isNotEmpty) {
        productFinder = inkWells;
      }

      if (productFinder != null && productFinder.evaluate().isNotEmpty) {
        await tester.tap(productFinder.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);

        TestUtils.logStep('Opened product detail');

        // Look for Add to Cart button
        final addToCartButton = find.textContaining('Add to Cart');
        if (addToCartButton.evaluate().isNotEmpty) {
          TestUtils.logStep('Add to Cart button found on product detail');
        }

        // Go back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
        }
      }

      TestUtils.logStep('Product detail test completed');
    });

    testWidgets('User can navigate between all main tabs', (tester) async {
      TestUtils.logStep('Starting tab navigation test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to each tab
      final tabs = ['Home', 'Search', 'Cart', 'Profile'];

      for (final tab in tabs) {
        await TestUtils.tapNavBarItem(tester, tab);
        await TestUtils.pauseForTelemetry(tester);
        TestUtils.logStep('Navigated to $tab tab');
      }

      // Return to Home
      await TestUtils.tapNavBarItem(tester, 'Home');
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Tab navigation test completed');
    });
  });
}
