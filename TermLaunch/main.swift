import Carbon
import Cocoa
import QuartzCore

class AppDelegate: NSObject, NSApplicationDelegate {
  var statusItem: NSStatusItem!
  var hotKeyRef: EventHotKeyRef?
  var menu: NSMenu!
  var animationTimer: Timer?

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
    animateMenuBarIcon()

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

  func animateMenuBarIcon() {
    guard let button = statusItem.button else { return }

    // Enable layer backing for Core Animation
    button.wantsLayer = true

    // Create opacity pulse animation (slower and repeating)
    let animation = CABasicAnimation(keyPath: "opacity")
    animation.fromValue = 1.0
    animation.toValue = 0.4
    animation.duration = 0.5  // Slower animation
    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    animation.repeatCount = .infinity  // Repeat until we stop it
    animation.autoreverses = true

    button.layer?.add(animation, forKey: "pulse")

    // Start checking if terminal has opened
    startCheckingForTerminal()
  }

  func startCheckingForTerminal() {
    // Cancel any existing timer
    animationTimer?.invalidate()

    // Check every 0.5 seconds if terminal app is running and in focus
    animationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      guard let self = self else { return }

      let terminal = self.selectedTerminal
      let bundleIds: [String: String] = [
        "Terminal": "com.apple.Terminal",
        "iTerm": "com.googlecode.iterm2",
        "Ghostty": "com.mitchellh.ghostty",
        "Warp": "dev.warp.Warp",
        "Kitty": "net.kovidgoyal.kitty",
      ]

      if let bundleId = bundleIds[terminal] {
        let runningApps = NSWorkspace.shared.runningApplications
        if runningApps.contains(where: { $0.bundleIdentifier == bundleId && $0.isActive }) {
          // Terminal is running and active, stop animation
          self.stopAnimation()
        }
      }
    }
  }

  func stopAnimation() {
    animationTimer?.invalidate()
    animationTimer = nil

    guard let button = statusItem.button else { return }
    button.layer?.removeAnimation(forKey: "pulse")

    // Reset opacity to normal
    if let layer = button.layer {
      layer.opacity = 1.0
    }
  }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
