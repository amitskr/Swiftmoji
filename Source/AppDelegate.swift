import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var keyboardManager: KeyboardManager?
    var floatingPanel: FloatingPanel?
    var preferencesWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register standard defaults
        UserDefaults.standard.register(defaults: [
            "soundEffects": true,
            "triggerCharacter": ":",
            "launchAtLogin": false,
            "skinTone": 0
        ])
        
        // 1. Check Accessibility Permissions on startup
        checkAccessibilityPermissions()
        
        // 2. Setup status menu bar icon
        setupStatusItem()
        
        // 3. Initialize floating HUD autocomplete panel
        setupFloatingPanel()
        
        // 4. Start monitoring keyboard input
        setupKeyboardManager()
    }
    
    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.title = "🚀"
            button.action = #selector(statusItemClicked)
            button.target = self
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "About Swiftmoji", action: #selector(aboutApp), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Check Accessibility Permissions", action: #selector(checkAccessibility), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Swiftmoji", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func statusItemClicked() {
        // Menu opens automatically on click
    }
    
    @objc func aboutApp() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func checkAccessibility() {
        let trusted = AXIsProcessTrusted()
        let alert = NSAlert()
        alert.messageText = trusted ? "Accessibility Permission Granted" : "Accessibility Permission Required"
        alert.informativeText = trusted 
            ? "Swiftmoji is active and has permission to monitor shortcodes globally to insert emojis."
            : "Swiftmoji needs Accessibility permission to monitor keyboard shortcuts and replace text in other applications.\n\nPlease enable it in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = trusted ? .informational : .warning
        
        if !trusted {
            alert.addButton(withTitle: "Open System Settings")
            alert.addButton(withTitle: "Cancel")
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                if let url = URL(string: urlString) {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            alert.runModal()
        }
    }
    
    func setupFloatingPanel() {
        floatingPanel = FloatingPanel()
    }
    
    func setupKeyboardManager() {
        guard let panel = floatingPanel else { return }
        keyboardManager = KeyboardManager(floatingPanel: panel)
        keyboardManager?.start()
    }
    
    func checkAccessibilityPermissions() {
        // Request permissions if not already granted. This causes macOS to pop up the dialog!
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func openPreferences() {
        if preferencesWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 400),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = "Swiftmoji Preferences"
            window.center()
            window.isReleasedWhenClosed = false
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            
            // Set SwiftUI View
            let hostingView = NSHostingView(rootView: PreferencesView())
            window.contentView = hostingView
            
            preferencesWindow = window
        }
        
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
