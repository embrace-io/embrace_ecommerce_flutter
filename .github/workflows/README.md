# CI/CD Workflows Documentation

This directory contains GitHub Actions workflows for automated testing and telemetry generation with the Embrace SDK.

## Overview

The CI setup mirrors the iOS Embrace Ecommerce app workflow architecture, adapted for Flutter:

| Workflow | Schedule | Purpose | Sessions/day |
|----------|----------|---------|--------------|
| `build.yml` | On push to main | Build artifacts for reuse | - |
| `ci-scheduled.yml` | Every 2 hours (:00) | Lightweight tests, non-stitched sessions | ~24 |
| `one-simulator.yml` | Every 2 hours (:30) | Sequential tests, stitched sessions | ~60 |
| `ci-full-matrix.yml` | Manual | Full device matrix testing | Variable |

## Workflow Details

### 1. build.yml - Build Artifacts Pipeline

**Triggers**: Push to `main`, manual dispatch

**Purpose**: Creates reusable build artifacts for both Android and iOS platforms.

**Jobs**:
- `build-android`: Builds debug APK and test APK
- `build-ios`: Builds iOS simulator app

**Artifacts Produced**:
- `android-build-artifacts` (7-day retention)
- `ios-build-artifacts` (7-day retention)

### 2. ci-scheduled.yml - Lightweight Scheduled Tests

**Triggers**: Cron `0 */2 * * *` (every 2 hours at :00), manual dispatch

**Purpose**: Generates a steady flow of **non-stitched sessions** to the Embrace dashboard.

**RUN_SOURCE**: `scheduled-browse-{platform}`

**Tests Run**: `browse_flow_test.dart` only (lightweight)

**Platforms**: Both Android (emulator) and iOS (simulator)

### 3. one-simulator.yml - Session Stitching Workflow

**Triggers**: Cron `30 */2 * * *` (every 2 hours at :30), manual dispatch

**Purpose**: Runs ALL tests **sequentially on the same device** to create stitched sessions (same device ID across multiple app sessions).

**RUN_SOURCE**: `one-simulator-stitched`

**Tests Run** (in order):
1. auth_flow_test.dart
2. browse_flow_test.dart
3. cart_flow_test.dart
4. search_flow_test.dart
5. checkout_flow_test.dart

**Key Features**:
- 5-second pause between tests for SDK data upload
- Uses `scripts/run-all-tests.sh` for orchestration
- Same device/emulator maintained throughout

### 4. ci-full-matrix.yml - Comprehensive Matrix Testing

**Triggers**: Manual dispatch only

**Purpose**: Full device matrix testing for pre-demo validation or comprehensive QA.

**Device Matrix**:

| Platform | Devices |
|----------|---------|
| Android | Pixel 8 (API 34), Pixel 6 (API 33), Pixel 4 (API 30) |
| iOS | iPhone 16, iPhone 15 Pro, iPhone SE (3rd gen) |
| Optional | iPad Pro, Pixel Tablet |

**Test Matrix**: All 5 test suites × all devices

**RUN_SOURCE Format**: `matrix-{test}-{platform}-{device}`

Examples:
- `matrix-auth-android-pixel-8`
- `matrix-browse-ios-iphone-16`
- `matrix-cart-ios-iphone-se-3rd-generation`

## Required Repository Configuration

### Variables (Settings > Secrets and variables > Actions > Variables)

| Variable | Required | Description |
|----------|----------|-------------|
| `EMBRACE_APP_ID` | Yes | Embrace App ID for SDK initialization |

### Secrets (Settings > Secrets and variables > Actions > Secrets)

| Secret | Required | Description |
|--------|----------|-------------|
| `EMBRACE_API_TOKEN` | Android only | API token for Android SDK |

## Integration Tests

Located in `/integration_test/`:

| File | Purpose |
|------|---------|
| `test_utils.dart` | Common utilities and helpers |
| `auth_flow_test.dart` | Authentication flows |
| `browse_flow_test.dart` | Product browsing flows |
| `cart_flow_test.dart` | Shopping cart operations |
| `search_flow_test.dart` | Search functionality |
| `checkout_flow_test.dart` | Checkout process |

## RUN_SOURCE Tracking

All tests pass `RUN_SOURCE` via `--dart-define` to identify test context in the Embrace dashboard:

```dart
// Access in test code
const runSource = String.fromEnvironment('RUN_SOURCE', defaultValue: 'local-test');
```

This allows filtering sessions by:
- `scheduled-*` - From scheduled workflow
- `one-simulator-*` - From stitching workflow
- `matrix-*` - From full matrix workflow
- `local-*` - Local development

## Local Development

### Run a single test locally:

```bash
flutter test integration_test/browse_flow_test.dart --dart-define=RUN_SOURCE=local-test
```

### Run all tests sequentially (stitched sessions):

```bash
./scripts/run-all-tests.sh ios local-stitched <SIMULATOR_UDID>
./scripts/run-all-tests.sh android local-stitched
```

### Get iOS Simulator UDID:

```bash
xcrun simctl list devices available | grep "iPhone"
```

## Session Output Estimates

| Workflow | Frequency | Sessions per run | Daily sessions |
|----------|-----------|------------------|----------------|
| ci-scheduled | 12x/day | 2 (1 per platform) | ~24 |
| one-simulator | 12x/day | 10 (5 tests × 2 platforms) | ~120 |
| ci-full-matrix | Manual | 30+ (depends on matrix) | On-demand |

**Combined daily output**: ~144 sessions automatically (50% stitched, 50% non-stitched)

## Troubleshooting

### Build failures
- Ensure `EMBRACE_APP_ID` variable is set
- Check Flutter version compatibility (requires 3.24.0+)

### Test failures
- Check simulator/emulator availability
- Review test artifacts for detailed logs
- Ensure app compiles locally first

### Missing sessions in dashboard
- Verify APP_ID matches your Embrace app
- Check API_TOKEN for Android
- Allow 1-2 minutes for session data to appear

## Dependabot

Add to `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```
