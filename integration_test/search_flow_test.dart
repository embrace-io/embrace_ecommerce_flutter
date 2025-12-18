import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:embrace_ecommerce_flutter/main.dart' as app;

import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search Flow Tests', () {
    testWidgets('User can access search screen', (tester) async {
      TestUtils.logStep('Starting search screen test - RUN_SOURCE: ${TestUtils.runSource}');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await TestUtils.tapNavBarItem(tester, 'Search');
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Navigated to Search');

      // Look for search input
      final searchField = find.byType(TextField);
      final searchBar = find.byType(SearchBar);

      if (searchField.evaluate().isNotEmpty || searchBar.evaluate().isNotEmpty) {
        TestUtils.logStep('Search input found');
      }

      await TestUtils.pauseForTelemetry(tester);
      TestUtils.logStep('Search screen test completed');
    });

    testWidgets('User can perform a search', (tester) async {
      TestUtils.logStep('Starting search query test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await TestUtils.tapNavBarItem(tester, 'Search');
      await tester.pumpAndSettle();

      // Find search input
      final searchFields = find.byType(TextField);
      final searchBar = find.byType(SearchBar);

      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'shoes');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);
        TestUtils.logStep('Entered search query: shoes');
      } else if (searchBar.evaluate().isNotEmpty) {
        await tester.tap(searchBar.first);
        await tester.pumpAndSettle();
        await tester.enterText(searchBar.first, 'shoes');
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);
        TestUtils.logStep('Entered search query in search bar');
      }

      // Look for search results
      final results = find.byType(Card);
      final listItems = find.byType(ListTile);

      if (results.evaluate().isNotEmpty) {
        TestUtils.logStep('Found ${results.evaluate().length} search results');
      } else if (listItems.evaluate().isNotEmpty) {
        TestUtils.logStep('Found ${listItems.evaluate().length} list items');
      }

      TestUtils.logStep('Search query test completed');
    });

    testWidgets('User can filter search results', (tester) async {
      TestUtils.logStep('Starting search filter test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await TestUtils.tapNavBarItem(tester, 'Search');
      await tester.pumpAndSettle();

      // Look for filter options
      final filterIcon = find.byIcon(Icons.filter_list);
      final filterButton = find.textContaining('Filter');
      final sortButton = find.textContaining('Sort');
      final categoryChips = find.byType(FilterChip);
      final choiceChips = find.byType(ChoiceChip);

      if (filterIcon.evaluate().isNotEmpty) {
        await tester.tap(filterIcon.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);
        TestUtils.logStep('Opened filter menu');

        // Close filter if opened as dialog/bottom sheet
        final closeButton = find.byIcon(Icons.close);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton.first);
          await tester.pumpAndSettle();
        }
      }

      if (categoryChips.evaluate().isNotEmpty) {
        await tester.tap(categoryChips.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);
        TestUtils.logStep('Tapped category filter chip');
      }

      if (choiceChips.evaluate().isNotEmpty) {
        await tester.tap(choiceChips.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);
        TestUtils.logStep('Tapped choice chip');
      }

      TestUtils.logStep('Search filter test completed');
    });

    testWidgets('User can select search result', (tester) async {
      TestUtils.logStep('Starting search result selection test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Search
      await TestUtils.tapNavBarItem(tester, 'Search');
      await tester.pumpAndSettle();

      // Enter a search query
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'shirt');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Look for and tap a result
        final results = find.byType(Card);
        if (results.evaluate().isNotEmpty) {
          await tester.tap(results.first);
          await tester.pumpAndSettle();
          await TestUtils.pauseForTelemetry(tester);
          TestUtils.logStep('Selected search result');

          // Go back
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
            await tester.pumpAndSettle();
          }
        }
      }

      TestUtils.logStep('Search result selection test completed');
    });
  });
}
