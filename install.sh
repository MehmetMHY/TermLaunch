#!/bin/bash

set -e

APP_PATH="/Applications/TermLaunch.app"
BUILD_DIR="build"
BUILD_APP="$BUILD_DIR/TermLaunch.app"

# Function to install
install() {
	# Check if already installed
	if [ -e "$APP_PATH" ]; then
		echo "TermLaunch is already installed at $APP_PATH"
		echo "To reinstall, run: ./install.sh -u && ./install.sh"
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
}

# Function to uninstall
uninstall() {
	if [ ! -e "$APP_PATH" ]; then
		echo "TermLaunch is not installed in /Applications"
		exit 1
	fi

	echo "Moving TermLaunch.app to Trash..."

	trash "$APP_PATH"

	if [ $? -eq 0 ]; then
		echo "TermLaunch has been moved to Trash"
	else
		echo "Failed to uninstall. You may need to close the app first or check permissions."
		exit 1
	fi
}

# Function to display help
help() {
	echo "TermLaunch Installation Script"
	echo ""
	echo "Usage: ./install.sh [OPTION]"
	echo ""
	echo "Options:"
	echo "  (no option)      Install TermLaunch"
	echo "  -u, --uninstall  Uninstall TermLaunch"
	echo "  -h, --help       Display this help message"
}

# Parse arguments
case "${1:-}" in
-u | --uninstall)
	uninstall
	;;
-h | --help)
	help
	;;
"" | *)
	install
	;;
esac
