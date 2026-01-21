import Carbon
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem!
  var hotKeyRef: EventHotKeyRef?
  var menu: NSMenu!

  let terminalApps = ["Terminal", "iTerm", "Ghostty", "Warp", "Kitty"]
  let selectedTerminalKey = "selectedTerminal"

  var selectedTerminal: String {
    get {
      UserDefaults.standard.string(forKey: selectedTerminalKey) ?? "Terminal"
    }
    set {
      UserDefaults.standard.set(newValue, forKey: selectedTerminalKey)
      updateMenuCheckmarks()
    }
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "desktopcomputer", accessibilityDescription: "Open Terminal")
    }

    setupMenu()
    registerHotKey()
  }

  func setupMenu() {
    menu = NSMenu()

    // Shortcut info (disabled, info only)
    let shortcutItem = NSMenuItem(title: "Shortcut: ⌥ Space", action: nil, keyEquivalent: "")
    shortcutItem.isEnabled = false
    menu.addItem(shortcutItem)

    // Open button
    let openItem = NSMenuItem(title: "Open", action: #selector(openTerminal), keyEquivalent: "")
    openItem.target = self
    menu.addItem(openItem)

    menu.addItem(NSMenuItem.separator())

    // Terminal submenu
    let terminalMenuItem = NSMenuItem(title: "Terminal", action: nil, keyEquivalent: "")
    let terminalSubmenu = NSMenu()

    for terminal in terminalApps {
      let item = NSMenuItem(
        title: terminal, action: #selector(selectTerminal(_:)), keyEquivalent: "")
      item.target = self
      item.representedObject = terminal
      if terminal == selectedTerminal {
        item.state = .on
      }
      terminalSubmenu.addItem(item)
    }

    terminalMenuItem.submenu = terminalSubmenu
    menu.addItem(terminalMenuItem)

    menu.addItem(NSMenuItem.separator())

    // Quit option
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
    quitItem.target = self
    menu.addItem(quitItem)

    statusItem.menu = menu
  }

  func updateMenuCheckmarks() {
    guard let terminalSubmenu = menu.item(withTitle: "Terminal")?.submenu else { return }
    for item in terminalSubmenu.items {
      item.state = (item.representedObject as? String) == selectedTerminal ? .on : .off
    }
  }

  @objc func selectTerminal(_ sender: NSMenuItem) {
    if let terminal = sender.representedObject as? String {
      selectedTerminal = terminal
    }
  }

  @objc func quitApp() {
    NSApplication.shared.terminate(nil)
  }

  func registerHotKey() {
    var hotKeyID = EventHotKeyID()
    hotKeyID.signature = OSType(0x5452_4D4C)  // "TRML"
    hotKeyID.id = 1

    var eventType = EventTypeSpec()
    eventType.eventClass = OSType(kEventClassKeyboard)
    eventType.eventKind = OSType(kEventHotKeyPressed)

    InstallEventHandler(
      GetApplicationEventTarget(),
      { _, event, _ -> OSStatus in
        NSApp.delegate?.perform(#selector(AppDelegate.openTerminal))
        return noErr
      }, 1, &eventType, nil, nil)

    // Option + Space: optionKey = 0x0800, Space keycode = 49
    let modifiers: UInt32 = UInt32(optionKey)
    let keyCode: UInt32 = 49

    RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
  }

  @objc func openTerminal() {
    let script: String

    switch selectedTerminal {
    case "iTerm":
      script = """
        tell application "iTerm"
            activate
            create window with default profile
        end tell
        """
    case "Ghostty":
      script = """
        tell application "Ghostty"
            activate
        end tell
        """
    case "Warp":
      script = """
        tell application "Warp"
            activate
        end tell
        """
    case "Kitty":
      script = """
        do shell script "open -na kitty"
        """
    default:  // Terminal
      script = """
        tell application "Terminal"
            activate
            do script ""
        end tell
        tell application "System Events"
            set frontmost of process "Terminal" to true
        end tell
        """
    }

    if let appleScript = NSAppleScript(source: script) {
      var error: NSDictionary?
      appleScript.executeAndReturnError(&error)
    }
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
