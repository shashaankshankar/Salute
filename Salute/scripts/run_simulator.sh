z#!/bin/bash
set -euo pipefail

DEVICE="iPhone 17"
SCHEME="Salute"
BUNDLE_ID="com.ShashaankShankar.Salute"
DESTINATION="platform=iOS Simulator,name=${DEVICE}"

# Boot the configured simulator if it is not already running.
if ! xcrun simctl list devices booted | grep -q "${DEVICE}"; then
  xcrun simctl boot "${DEVICE}"
fi

open -a Simulator

xcodebuild -scheme "${SCHEME}" -destination "${DESTINATION}" build

APP_PATH="$(xcodebuild -scheme "${SCHEME}" -destination "${DESTINATION}" -showBuildSettings | awk '/BUILT_PRODUCTS_DIR/ {print $3; exit}')/${SCHEME}.app"

xcrun simctl install booted "${APP_PATH}"
xcrun simctl launch booted "${BUNDLE_ID}"
