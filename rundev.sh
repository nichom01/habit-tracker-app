#!/bin/bash

# rundev.sh - Build and run HabitTracker iOS app in simulator
# Usage: ./rundev.sh [simulator-name]
# Example: ./rundev.sh "iPhone 17"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Scheme and workspace
SCHEME="HabitTracker"
WORKSPACE="HabitTracker.xcworkspace"
PLATFORM="iOS Simulator"

# Default simulator (iPhone 17 Pro - a common modern device)
DEFAULT_SIMULATOR="iPhone 17 Pro"

# Allow override via command line argument
SIMULATOR_NAME="${1:-$DEFAULT_SIMULATOR}"

echo -e "${GREEN}🚀 Building and running HabitTracker on ${SIMULATOR_NAME}...${NC}"

# Check if workspace exists
if [ ! -d "$WORKSPACE" ]; then
    echo -e "${RED}❌ Error: Workspace not found at $WORKSPACE${NC}"
    exit 1
fi

# Get simulator UDID first
echo -e "${YELLOW}🔍 Finding simulator...${NC}"
SIMULATOR_UDID=$(xcrun simctl list devices available | grep "$SIMULATOR_NAME" | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | head -n 1)

if [ -z "$SIMULATOR_UDID" ]; then
    echo -e "${RED}❌ Error: Simulator '${SIMULATOR_NAME}' not found${NC}"
    echo -e "${YELLOW}Available simulators:${NC}"
    xcrun simctl list devices available | grep "iPhone\|iPad" | head -10
    exit 1
fi

# Boot simulator if not already booted
BOOT_STATUS=$(xcrun simctl list devices | grep "$SIMULATOR_UDID" | grep -oE '(Booted|Shutdown)')
if [ "$BOOT_STATUS" != "Booted" ]; then
    echo -e "${YELLOW}📱 Booting simulator...${NC}"
    xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true
fi

# Open Simulator app
open -a Simulator

# Wait a moment for simulator to be ready
sleep 2

# Build the app
echo -e "${YELLOW}📦 Building for simulator...${NC}"
xcodebuild \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "id=$SIMULATOR_UDID" \
    -derivedDataPath build \
    clean build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

# Find the app bundle
APP_PATH=$(find build -name "HabitTracker.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Error: Could not find app bundle in build directory${NC}"
    exit 1
fi

# Install the app
echo -e "${YELLOW}📱 Installing app on simulator...${NC}"
xcrun simctl install "$SIMULATOR_UDID" "$APP_PATH"

# Get bundle ID from Info.plist
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null || echo "com.habittracker.app")

# Launch the app
echo -e "${YELLOW}🚀 Launching app...${NC}"
xcrun simctl launch "$SIMULATOR_UDID" "$BUNDLE_ID"

echo -e "${GREEN}✅ App launched successfully!${NC}"
echo -e "${GREEN}   Simulator: ${SIMULATOR_NAME} (${SIMULATOR_UDID})${NC}"

