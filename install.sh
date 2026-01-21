#!/bin/bash

set -e

APP_PATH="/Applications/TermLaunch.app"
BUILD_DIR="build"
BUILD_APP="$BUILD_DIR/TermLaunch.app"

# Check if already installed
if [ -e "$APP_PATH" ]; then
	echo "TermLaunch is already installed at $APP_PATH"
	echo "To reinstall, run: ./uninstall.sh && ./install.sh"
	exit 1
fi

# Build the app
echo "Building TermLaunch..."
bash build.sh

# Copy to Applications
echo "Installing TermLaunch to /Applications..."
cp -r "$BUILD_APP" /Applications/

echo ""
echo "✓ TermLaunch installed successfully!"
echo ""
echo "To launch the app:"
echo "  open /Applications/TermLaunch.app"
echo ""
echo "Or use the hotkey: ⌥ Space (Option + Space)"
