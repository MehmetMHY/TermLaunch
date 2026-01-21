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
		echo "To reinstall, run: ./install.sh -d && ./install.sh"
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

# Function to run the app
run() {
	pkill -x TermLaunch 2>/dev/null || true

	if [ ! -d "$BUILD_DIR" ]; then
		echo "Error: $BUILD_DIR directory does not exist. Please build the app first."
		exit 1
	fi

	if [ ! -d "$BUILD_APP" ]; then
		echo "Error: $BUILD_APP not found."
		exit 1
	fi

	open "$BUILD_APP"
}

# Function to update
update() {
	if [ ! -e "$APP_PATH" ]; then
		echo "TermLaunch is not installed. Run: ./install.sh to install first."
		exit 1
	fi

	# Check if TermLaunch is running
	WAS_RUNNING=false
	if pgrep -x TermLaunch >/dev/null 2>&1; then
		WAS_RUNNING=true
	fi

	echo "Stopping TermLaunch..."
	pkill -x TermLaunch 2>/dev/null || true

	echo "Building TermLaunch..."
	bash build.sh

	echo "Updating TermLaunch..."
	rm -rf "$APP_PATH"
	cp -r "$BUILD_APP" /Applications/

	echo ""
	echo "✓ TermLaunch updated successfully!"
	echo ""

	# Reopen if it was running
	if [ "$WAS_RUNNING" = true ]; then
		echo "Relaunching TermLaunch..."
		open "$APP_PATH"
	else
		echo "To launch the app:"
		echo "  open /Applications/TermLaunch.app"
		echo ""
		echo "Or use the hotkey: ⌥ Space (Option + Space)"
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
	echo "  -d, --uninstall  Uninstall TermLaunch"
	echo "  -u, --update     Update TermLaunch to the latest build"
	echo "  -r, --run        Run the built app"
	echo "  -h, --help       Display this help message"
}

# Parse arguments
case "${1:-}" in
-d | --uninstall)
	uninstall
	;;
-u | --update)
	update
	;;
-r | --run)
	run
	;;
-h | --help)
	help
	;;
"" | *)
	install
	;;
esac
