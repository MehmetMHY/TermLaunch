#!/usr/bin/env bash

pkill -x TermLaunch 2>/dev/null || true

if [ ! -d "./build" ]; then
	echo "Error: ./build directory does not exist. Please build the app first."
	exit 1
fi

if [ ! -d "./build/TermLaunch.app" ]; then
	echo "Error: ./build/TermLaunch.app not found."
	exit 1
fi

open "./build/TermLaunch.app"
