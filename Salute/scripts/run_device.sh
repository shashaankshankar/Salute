#!/bin/bash

set -euo pipefail

# ==============================================
# Run the Salute app on Shashaank's iPhone
# ==============================================

SCHEME="Salute"
BUNDLE_ID="com.ShashaankShankar.Salute"
CONFIGURATION="Debug"
DEVICE_NAME="Shashaank's iPhone"
# Some tooling still reports the device name with a smart apostrophe
ALT_DEVICE_NAME="Shashaank’s iPhone"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/Salute.xcodeproj"
DERIVED_DATA_PATH="$PROJECT_DIR/build/device"

if [ ! -d "$PROJECT_FILE" ]; then
    echo "Expected Xcode project not found at $PROJECT_FILE"
    exit 1
fi

echo "Checking for connected devices..."
DEVICES="$(xcrun xctrace list devices 2>/dev/null || true)"

if [ -z "$DEVICES" ]; then
    echo "No devices reported. Make sure your iPhone is connected, unlocked, and trusted."
    exit 1
fi

if echo "$DEVICES" | grep -Fq "$DEVICE_NAME"; then
    DEVICE_MATCH="$DEVICE_NAME"
elif echo "$DEVICES" | grep -Fq "$ALT_DEVICE_NAME"; then
    DEVICE_MATCH="$ALT_DEVICE_NAME"
else
    echo "Could not find $DEVICE_NAME in the available device list."
    echo "Available devices:"
    echo "$DEVICES"
    exit 1
fi

DEVICE_LINE="$(echo "$DEVICES" | grep -F "$DEVICE_MATCH" | head -n 1 || true)"
DEVICE_UDID="$(echo "$DEVICE_LINE" | sed -n 's/.* (\([0-9A-Fa-f-]*\))$/\1/p')"

if [ -z "$DEVICE_UDID" ]; then
    echo "Failed to parse the UDID for $DEVICE_MATCH."
    exit 1
fi

echo "Using device $DEVICE_MATCH (UDID: $DEVICE_UDID)"
mkdir -p "$DERIVED_DATA_PATH"

echo "Building $SCHEME for $DEVICE_MATCH..."
xcodebuild \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "id=$DEVICE_UDID" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    build

echo "Resolving built app path..."
BUILD_SETTINGS="$(xcodebuild \
    -project "$PROJECT_FILE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -destination "id=$DEVICE_UDID" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -showBuildSettings)"

FULL_PRODUCT_NAME="$(echo "$BUILD_SETTINGS" | sed -n 's/^[[:space:]]*FULL_PRODUCT_NAME = //p' | head -n 1)"
TARGET_BUILD_DIR="$(echo "$BUILD_SETTINGS" | sed -n 's/^[[:space:]]*TARGET_BUILD_DIR = //p' | head -n 1)"

if [ -z "$FULL_PRODUCT_NAME" ] || [ -z "$TARGET_BUILD_DIR" ]; then
    echo "Unable to determine the built app path from build settings."
    exit 1
fi

APP_PATH="$TARGET_BUILD_DIR/$FULL_PRODUCT_NAME"

if [ ! -d "$APP_PATH" ]; then
    echo "Build succeeded but the app bundle was not found at $APP_PATH."
    exit 1
fi

echo "Installing the app on $DEVICE_MATCH..."
xcrun devicectl device install app --device "$DEVICE_UDID" "$APP_PATH"

echo "Launching $BUNDLE_ID on the device..."
xcrun devicectl device process launch --terminate-existing --device "$DEVICE_UDID" "$BUNDLE_ID"

echo "App should now be running on $DEVICE_MATCH."
