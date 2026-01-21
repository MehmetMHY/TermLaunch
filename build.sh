#!/bin/bash

set -e

APP_NAME="TermLaunch"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

# clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# compile swift code
swiftc -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
	-framework Cocoa \
	TermLaunch/main.swift

# copy Info.plist
cp TermLaunch/Info.plist "$APP_BUNDLE/Contents/"

# copy app icon
cp TermLaunch/AppIcon.icns "$APP_BUNDLE/Contents/Resources/"

echo "Build complete: $APP_BUNDLE"
echo ""
echo "To install, run:"
echo "  cp -r $APP_BUNDLE /Applications/"
echo ""
echo "To run directly:"
echo "  open $APP_BUNDLE"
