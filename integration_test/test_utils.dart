import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test utilities and helpers for integration tests
class TestUtils {
  /// Get RUN_SOURCE from environment
  static String get runSource {
    return const String.fromEnvironment('RUN_SOURCE', defaultValue: 'local-test');
  }

  /// Wait for the app to settle after navigation
  static Future<void> settleApp(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  /// Wait for network operations to complete
  static Future<void> waitForNetwork(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  /// Tap on navigation bar item by label
  static Future<void> tapNavBarItem(WidgetTester tester, String label) async {
    final navItem = find.text(label);
    expect(navItem, findsOneWidget, reason: 'Navigation item "$label" should exist');
    await tester.tap(navItem);
    await settleApp(tester);
  }

  /// Scroll until widget is visible
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder finder, {
    Finder? scrollable,
    double delta = 100,
    int maxScrolls = 50,
  }) async {
    final scrollableFinder = scrollable ?? find.byType(Scrollable).first;

    int scrollCount = 0;
    while (scrollCount < maxScrolls) {
      if (finder.evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(scrollableFinder, Offset(0, -delta));
      await tester.pumpAndSettle();
      scrollCount++;
    }
  }

  /// Find widget by key string
  static Finder findByKeyString(String key) {
    return find.byKey(Key(key));
  }

  /// Verify screen is displayed
  static Future<void> verifyScreenDisplayed(
    WidgetTester tester,
    String screenIdentifier,
  ) async {
    await settleApp(tester);
    // Try to find by key first, then by text
    final byKey = find.byKey(Key(screenIdentifier));
    final byText = find.text(screenIdentifier);

    expect(
      byKey.evaluate().isNotEmpty || byText.evaluate().isNotEmpty,
      isTrue,
      reason: 'Screen "$screenIdentifier" should be displayed',
    );
  }

  /// Log test step for debugging
  static void logStep(String step) {
    debugPrint('[TEST STEP] $step');
  }

  /// Pause to allow SDK to record telemetry
  static Future<void> pauseForTelemetry(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
  }
}

/// Extension methods for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Tap a widget and wait for settling
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Enter text in a field and wait
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}
