#!/bin/bash

APP_PATH="/Applications/TermLaunch.app"

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
