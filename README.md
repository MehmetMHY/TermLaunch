# TermLaunch

## About

A lightweight macOS menu bar utility to quickly open your favorite terminal application.

## Features

- **Menu bar icon** - Quick access from anywhere with a click
- **Global hotkey** - Press `⌥ Space` (Option + Space) to open terminal instantly
- **Multiple terminal support** - Choose from Terminal, iTerm, Ghostty, Warp, or Kitty
- **Persistent selection** - Your terminal preference is saved between launches
- **Minimal footprint** - Runs as an accessory app in the menu bar

## Installation

### Build and Install from Source

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/open_terminal_menu_bar_macos.git
   cd open_terminal_menu_bar_macos
   ```

2. Run the install script:

   ```bash
   ./install.sh
   ```

   This will build the app and install it to `/Applications/`.

Alternatively, if you want to build without installing:

```bash
./build.sh
open build/TermLaunch.app
```

### Start at Login

To have TermLaunch automatically open when you log in:

1. Open **System Settings** (or System Preferences)
2. Go to **General** → **Login Items**
3. Click the **+** button under "Open at Login"
4. Navigate to `/Applications` and select **TermLaunch.app**
5. Click **Add**

TermLaunch will now automatically start whenever you log in.

## Usage

### Via Menu

Click the menu bar icon (⌨️) to open the menu:

- **Shortcut: ⌥ Space** - Shows the hotkey for quick reference
- **Open** - Opens your selected terminal
- **Terminal** - Submenu to select which terminal to use
- **Quit** - Close the app

### Via Hotkey

Press `⌥ Space` (Option + Space) at any time to instantly open your selected terminal.

### Select Your Terminal

1. Click the menu bar icon
2. Hover over "Terminal"
3. Select your preferred terminal:
   - Terminal (default macOS Terminal)
   - iTerm
   - Ghostty
   - Warp
   - Kitty

Your selection is automatically saved and will be used for future launches.

## Supported Terminals

- **Terminal** - Default macOS terminal application
- **iTerm** - Feature-rich terminal emulator
- **Ghostty** - Modern terminal emulator
- **Warp** - AI-powered terminal
- **Kitty** - GPU-based terminal emulator

## Requirements

- macOS 12.0 or later
- Swift compiler (included with Xcode)

## Building

The project uses Swift and compiles with the system frameworks:

- Cocoa - macOS user interface
- Carbon - For global hotkey support

```bash
./build.sh
```

This will create `build/TermLaunch.app`.

### Generating App Icon

The app icon is generated from `logo.png` using the `generate_icon.py` script. To regenerate the icon (for example, if you modify the logo):

```bash
python3 generate_icon.py
```

This creates an `AppIcon.icns` file with all required macOS icon sizes and proper padding. The icon is automatically included in the build process.

### Python Requirements for Icon Generation

To use `generate_icon.py`, install the Python dependencies from `requirements.txt`:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Uninstalling

To uninstall TermLaunch from `/Applications`:

```bash
./uninstall.sh
```

This safely moves the app to Trash instead of permanently deleting it.

To reinstall after uninstalling:

```bash
./uninstall.sh && ./install.sh
```

## Development

The app is implemented in a single file: `TermLaunch/main.swift`

Key components:

- `AppDelegate` - Main application controller
- `setupMenu()` - Initializes the menu bar menu
- `registerHotKey()` - Sets up the Option + Space hotkey
- `openTerminal()` - Opens the selected terminal with appropriate AppleScript
- `UserDefaults` - Persists terminal selection preference
