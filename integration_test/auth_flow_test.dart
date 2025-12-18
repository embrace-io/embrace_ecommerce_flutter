import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:embrace_ecommerce_flutter/main.dart' as app;

import 'test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Tests', () {
    testWidgets('User can access profile as guest', (tester) async {
      TestUtils.logStep('Starting guest auth flow - RUN_SOURCE: ${TestUtils.runSource}');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile tab
      await TestUtils.tapNavBarItem(tester, 'Profile');
      await TestUtils.pauseForTelemetry(tester);

      TestUtils.logStep('Navigated to Profile');

      // Look for sign in or guest options
      final signInButton = find.textContaining('Sign In');
      final guestButton = find.textContaining('Guest');
      final continueAsGuest = find.textContaining('Continue as Guest');

      if (signInButton.evaluate().isNotEmpty) {
        TestUtils.logStep('Sign In option found');
      }

      if (guestButton.evaluate().isNotEmpty || continueAsGuest.evaluate().isNotEmpty) {
        TestUtils.logStep('Guest option found');
        final guestFinder = guestButton.evaluate().isNotEmpty ? guestButton : continueAsGuest;
        await tester.tap(guestFinder.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);
      }

      TestUtils.logStep('Guest auth flow completed');
    });

    testWidgets('User can view auth screen options', (tester) async {
      TestUtils.logStep('Starting auth options test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile
      await TestUtils.tapNavBarItem(tester, 'Profile');
      await tester.pumpAndSettle();

      // Look for various auth options
      final emailAuth = find.textContaining('Email');
      final googleAuth = find.textContaining('Google');
      final appleAuth = find.textContaining('Apple');
      final biometricAuth = find.byIcon(Icons.fingerprint);

      if (emailAuth.evaluate().isNotEmpty) {
        TestUtils.logStep('Email auth option found');
      }
      if (googleAuth.evaluate().isNotEmpty) {
        TestUtils.logStep('Google auth option found');
      }
      if (appleAuth.evaluate().isNotEmpty) {
        TestUtils.logStep('Apple auth option found');
      }
      if (biometricAuth.evaluate().isNotEmpty) {
        TestUtils.logStep('Biometric auth option found');
      }

      await TestUtils.pauseForTelemetry(tester);
      TestUtils.logStep('Auth options test completed');
    });

    testWidgets('User can navigate to email auth screen', (tester) async {
      TestUtils.logStep('Starting email auth navigation test');

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to Profile
      await TestUtils.tapNavBarItem(tester, 'Profile');
      await tester.pumpAndSettle();

      // Look for email sign in option
      final emailOption = find.textContaining('Email');
      if (emailOption.evaluate().isNotEmpty) {
        await tester.tap(emailOption.first);
        await tester.pumpAndSettle();
        await TestUtils.pauseForTelemetry(tester);

        // Look for email/password fields
        final emailField = find.byType(TextField);
        if (emailField.evaluate().isNotEmpty) {
          TestUtils.logStep('Email input field found');
        }

        // Go back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
        }
      }

      TestUtils.logStep('Email auth navigation test completed');
    });
  });
}
