#!/bin/bash

# Run all integration tests sequentially on the same device
# This creates stitched sessions (same device ID across multiple sessions)
#
# Usage:
#   ./scripts/run-all-tests.sh <platform> <run_source> [device_id]
#
# Arguments:
#   platform   - 'android' or 'ios'
#   run_source - Identifier for this test run (e.g., 'one-simulator-stitched')
#   device_id  - (iOS only) Simulator UDID

set -e

PLATFORM="${1:-android}"
RUN_SOURCE="${2:-local-stitched}"
DEVICE_ID="${3:-}"

# Test files to run sequentially
TESTS=(
    "auth_flow_test.dart"
    "browse_flow_test.dart"
    "cart_flow_test.dart"
    "search_flow_test.dart"
    "checkout_flow_test.dart"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Running all tests sequentially"
echo "Platform: $PLATFORM"
echo "RUN_SOURCE: $RUN_SOURCE"
if [ -n "$DEVICE_ID" ]; then
    echo "Device ID: $DEVICE_ID"
fi
echo "=========================================="

# Create results directory
mkdir -p test-results

PASSED=0
FAILED=0
TOTAL=${#TESTS[@]}

for TEST in "${TESTS[@]}"; do
    echo ""
    echo -e "${YELLOW}[TEST] Running $TEST${NC}"
    echo "----------------------------------------"

    TEST_NAME="${TEST%.dart}"
    RESULT_FILE="test-results/result-${TEST_NAME}.txt"

    # Build the flutter test command
    if [ "$PLATFORM" == "ios" ] && [ -n "$DEVICE_ID" ]; then
        CMD="flutter test integration_test/$TEST --dart-define=RUN_SOURCE=${RUN_SOURCE} -d $DEVICE_ID"
    else
        CMD="flutter test integration_test/$TEST --dart-define=RUN_SOURCE=${RUN_SOURCE}"
    fi

    # Run the test and capture result
    if $CMD > "$RESULT_FILE" 2>&1; then
        echo -e "${GREEN}[PASS] $TEST${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}[FAIL] $TEST${NC}"
        FAILED=$((FAILED + 1))
        # Print last 20 lines of output for failed tests
        echo "Last 20 lines of output:"
        tail -20 "$RESULT_FILE"
    fi

    # Pause between tests to allow SDK to flush data
    echo "Pausing 5 seconds for SDK data upload..."
    sleep 5
done

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo "=========================================="

# Exit with failure if any tests failed
if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
