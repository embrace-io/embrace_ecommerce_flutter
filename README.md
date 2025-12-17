# Embrace E-commerce Flutter

A Flutter E-commerce demo application with full Embrace SDK integration for mobile telemetry demonstration.

## Overview

This app is a Flutter port of the iOS Embrace E-commerce app, designed to showcase Embrace SDK telemetry capabilities across both iOS and Android platforms.

## Features

### E-commerce Functionality
- **Product Catalog**: Browse featured products, new arrivals, and daily deals
- **Search**: Search products with recent search history
- **Shopping Cart**: Add/remove items, quantity management, persistent cart
- **Checkout**: 4-step checkout flow (Cart Review → Shipping → Payment → Confirmation)
- **User Profile**: Edit profile, manage addresses, payment methods, order history
- **Authentication**: Email, Google Sign-In, Biometric (Face ID/Touch ID), Guest checkout

### Embrace SDK Integration
- **Spans**: Performance tracking for all API calls and user flows
- **Logs**: Info, Warning, Error, Debug levels with custom properties
- **Breadcrumbs**: User journey tracking across screens
- **Session Properties**: User context and metadata
- **User Identification**: User ID and persona tracking
- **Crash Reporting**: Intentional crash simulation for testing

## Embrace Telemetry Tracking

### E-commerce Events
- Product views
- Add to cart / Remove from cart
- Cart viewed
- Checkout started / step completed
- Purchase attempt / success / failure

### User Flow Breadcrumbs
- `CHECKOUT_STARTED`
- `SHIPPING_INFORMATION_COMPLETED`
- `CHECKOUT_SHIPPING_COMPLETED`
- `STRIPE_PAYMENT_PROCESSING_STARTED`
- `STRIPE_PAYMENT_PROCESSING_SUCCESS/FAILED`
- `CHECKOUT_PAYMENT_COMPLETED`
- `PLACE_ORDER_INITIATED`
- `ORDER_DETAILS_API_COMPLETED`
- `ORDER_PLACED_SUCCESS/FAILED`

### Authentication Events
- Login attempts (by method)
- Login success/failure
- User logout

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0+
- iOS 13.0+ / Android API 21+
- Embrace App ID and API Token

### Installation

1. **Install Flutter dependencies**:
   ```bash
   cd embrace_ecommerce_flutter
   flutter pub get
   ```

2. **Configure Embrace SDK** (config files are gitignored for security):

   **iOS**:
   ```bash
   cp ios/Runner/EmbraceConfig.plist.sample ios/Runner/EmbraceConfig.plist
   ```
   Then edit `ios/Runner/EmbraceConfig.plist` and replace `YOUR_EMBRACE_APP_ID` with your actual app ID.

   **Important**: After running `flutter pub get`, open `ios/Runner.xcworkspace` in Xcode and add `EmbraceConfig.plist` to the Runner target:
   - Right-click on Runner folder → Add Files to "Runner"
   - Select `EmbraceConfig.plist`
   - Ensure "Copy items if needed" is unchecked and target membership includes Runner

   **Android**:
   ```bash
   cp android/app/src/main/embrace-config.json.sample android/app/src/main/embrace-config.json
   ```
   Then edit `android/app/src/main/embrace-config.json` and replace placeholders with your credentials.

3. **Run the app**:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
├── services/                    # Business logic
│   ├── embrace_service.dart     # Embrace SDK wrapper
│   ├── api_service.dart         # API client
│   ├── mock_data_service.dart   # Mock data
│   └── auth_service.dart        # Authentication
├── providers/                   # State management (Provider)
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── product_provider.dart
│   └── checkout_provider.dart
├── screens/                     # UI screens
│   ├── home/
│   ├── search/
│   ├── cart/
│   ├── profile/
│   ├── product/
│   ├── checkout/
│   └── auth/
├── widgets/                     # Reusable components
└── utils/                       # Constants and utilities
```

## Architecture

- **State Management**: Provider
- **Navigation**: go_router with nested navigation
- **Architecture Pattern**: Service/Provider pattern (similar to iOS MVVM)

## Embrace SDK Features Used

| Feature | Implementation |
|---------|----------------|
| Spans | `Embrace.instance.startSpan()` |
| Logs | `Embrace.instance.logInfo/Warning/Error()` |
| Breadcrumbs | `Embrace.instance.addBreadcrumb()` |
| Session Properties | `Embrace.instance.addSessionProperty()` |
| User ID | `Embrace.instance.setUserIdentifier()` |
| User Persona | `Embrace.instance.addUserPersona()` |

## Testing Embrace Integration

1. **View Sessions**: Check Embrace dashboard for active sessions
2. **Test Spans**: Navigate through the app, perform actions
3. **Test Breadcrumbs**: Complete a checkout flow
4. **Test Crash Reporting**: Use Profile → Force Crash button

## Dependencies

- `embrace` - Embrace Flutter SDK
- `provider` - State management
- `go_router` - Navigation
- `shared_preferences` - Local storage
- `cached_network_image` - Image caching
- `local_auth` - Biometric authentication

## Related

- [Embrace Flutter SDK](https://github.com/embrace-io/embrace-flutter-sdk)
- [Embrace Documentation](https://embrace.io/docs/flutter/)
