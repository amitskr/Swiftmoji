import Cocoa
import ApplicationServices
import SwiftUI

// Global event tap callback
func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let manager = KeyboardManager.shared else {
        return Unmanaged.passUnretained(event)
    }
    
    if manager.isAutoCompleting {
        return Unmanaged.passUnretained(event)
    }
    
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        // Re-enable the tap if macOS disables it
        if let tap = manager.eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
        }
        return Unmanaged.passUnretained(event)
    }
    
    if type == .keyDown {
        if let nsEvent = NSEvent(cgEvent: event) {
            let processed = manager.handleKeyEvent(nsEvent, event: event)
            if processed {
                return nil // Swallow the key
            }
        }
    }
    
    return Unmanaged.passUnretained(event)
}

class KeyboardManager {
    static var shared: KeyboardManager?
    
    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    let floatingPanel: FloatingPanel
    
    // Autocomplete tracking state
    var isTracking = false
    var currentQuery = ""
    var selectedIndex = 0
    var matches: [EmojiItem] = []
    
    // Safety guard to avoid recursive loops when inserting emojis
    var isAutoCompleting = false
    
    // Screen coordinates for caret
    var caretPosition: CGPoint = .zero
    
    var triggerCharacter: String {
        return UserDefaults.standard.string(forKey: "triggerCharacter") ?? ":"
    }
    
    init(floatingPanel: FloatingPanel) {
        self.floatingPanel = floatingPanel
        KeyboardManager.shared = self
    }
    
    func start() {
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        
        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: eventTapCallback,
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            return
        }
        
        self.eventTap = tap
        self.runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        print("KeyboardManager active and hook registered.")
    }
    
    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
    }
    
    // Main key event processing
    func handleKeyEvent(_ nsEvent: NSEvent, event: CGEvent) -> Bool {
        let keyCode = nsEvent.keyCode
        let chars = nsEvent.characters ?? ""
        
        let isEscape = keyCode == 53
        let isEnter = keyCode == 36 || keyCode == 76
        let isTab = keyCode == 48
        let isBackspace = keyCode == 51
        let isArrowDown = keyCode == 125
        let isArrowUp = keyCode == 126
        
        if !isTracking {
            // Trigger character starts autocomplete tracking
            if chars == triggerCharacter {
                // Find screen caret position
                if let caretRect = getCaretScreenPosition() {
                    caretPosition = CGPoint(x: caretRect.origin.x + caretRect.width / 2, y: caretRect.origin.y)
                } else {
                    // Fallback to mouse pointer position
                    let mouseLoc = NSEvent.mouseLocation
                    caretPosition = CGPoint(x: mouseLoc.x, y: mouseLoc.y)
                }
                
                isTracking = true
                currentQuery = ""
                selectedIndex = 0
                matches = []
                
                // Do not swallow the initial `:` - we want it typed in the text area!
                return false
            }
            return false
        } else {
            // Active tracking session
            
            // If the user types the closing trigger and we have a valid selection, complete it!
            if chars == triggerCharacter && !matches.isEmpty {
                insertSelectedEmoji()
                return true // Swallow the trigger and insert
            }
            
            if isEscape {
                cancelTracking()
                return true // Swallow escape to close the panel cleanly
            }
            
            let totalItems = matches.count + 1
            
            if isArrowDown {
                selectedIndex = (selectedIndex + 1) % totalItems
                updateUI()
                return true // Swallow arrow
            }
            
            if isArrowUp {
                selectedIndex = (selectedIndex - 1 + totalItems) % totalItems
                updateUI()
                return true // Swallow arrow
            }
            
            if isEnter || isTab {
                insertSelectedEmoji()
                return true // Swallow enter/tab and auto-complete
            }
            
            if isBackspace {
                if currentQuery.isEmpty {
                    cancelTracking()
                    return false // Let backspace delete the leading `:`
                } else {
                    currentQuery.removeLast()
                    filterEmojis()
                    return false // Let backspace delete character normally
                }
            }
            
            // Only allow standard shortcode characters (alphanumeric, underscore, plus, minus)
            if let firstChar = chars.first {
                let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_+-"))
                if allowed.contains(UnicodeScalar(String(firstChar))!) {
                    currentQuery.append(firstChar)
                    filterEmojis()
                    return false // Let character propagate to text editor
                } else {
                    // Any other character (space, slash, punctuation) breaks the tracking
                    cancelTracking()
                    return false // Let the character pass through
                }
            }
            
            return false
        }
    }
    
    func insertSelectedEmoji() {
        let shortcutLength = currentQuery.count + 1 // Query characters + leading trigger
        
        isAutoCompleting = true
        
        // Hide panel immediately for instantaneous UI feel
        floatingPanel.hidePanel()
        isTracking = false
        
        // Delete the shortcut by posting backspaces
        sendBackspace(count: shortcutLength)
        
        if selectedIndex == matches.count {
            // Option "Browse all emoji..." is selected.
            // Trigger standard macOS Emoji & Symbols palette
            triggerEmojiPicker()
        } else if selectedIndex >= 0 && selectedIndex < matches.count {
            // Standard emoji selection
            let baseEmoji = matches[selectedIndex].emoji
            var finalEmoji = baseEmoji
            
            // Apply skin tone modifier if applicable
            let tone = UserDefaults.standard.integer(forKey: "skinTone")
            let skinToneModifiers = ["", "🏻", "🏼", "🏽", "🏾", "🏿"]
            let skinToneSupportedBaseEmojis: Set<String> = [
                "👍", "👎", "👋", "🤚", "🖐️", "✋", "🖖", "👌", "🤌", "🤏",
                "✌️", "🤞", "🤟", "🤘", "🤙", "👈", "👉", "👆", "🖕", "👇",
                "☝️", "✊", "👊", "🤛", "🤜", "👏", "🙌", "👐", "🤲", "🤝",
                "🙏", "✍️", "💅", "🤳", "💪", "👂", "👃"
            ]
            
            if tone > 0 && tone < skinToneModifiers.count {
                if skinToneSupportedBaseEmojis.contains(baseEmoji) {
                    finalEmoji = baseEmoji + skinToneModifiers[tone]
                }
            }
            
            typeString(finalEmoji)
            
            // Play pop sound if enabled
            if UserDefaults.standard.bool(forKey: "soundEffects") {
                NSSound(named: "Pop")?.play()
            }
        }
        
        isAutoCompleting = false
    }
    
    func cancelTracking() {
        isTracking = false
        floatingPanel.hidePanel()
    }
    
    func filterEmojis() {
        if currentQuery.isEmpty {
            // Show top popular emojis if query is empty
            matches = Array(EmojiDatabase.shared.allEmojis.prefix(5))
        } else {
            let lowerQuery = currentQuery.lowercased()
            matches = EmojiDatabase.shared.allEmojis.filter { item in
                item.shortcode.lowercased().contains(lowerQuery)
            }
            
            // Sort matches: exact prefix matches first
            matches.sort { a, b in
                let aStarts = a.shortcode.lowercased().hasPrefix(lowerQuery)
                let bStarts = b.shortcode.lowercased().hasPrefix(lowerQuery)
                if aStarts && !bStarts { return true }
                if !aStarts && bStarts { return false }
                return a.shortcode.lowercased() < b.shortcode.lowercased()
            }
            
            // Limit to 6 matches for HUD scroll readability
            matches = Array(matches.prefix(6))
        }
        
        selectedIndex = 0
        updateUI()
    }
    
    func updateUI() {
        if !isTracking {
            floatingPanel.hidePanel()
            return
        }
        
        // Render AutocompleteView inside floating panel hosted via NSHostingView
        let hostingView = NSHostingView(rootView: AutocompleteView(
            matches: matches,
            selectedIndex: selectedIndex,
            query: currentQuery
        ))
        
        floatingPanel.show(at: caretPosition, content: hostingView)
    }
    
    private func sendBackspace(count: Int) {
        let source = CGEventSource(stateID: .hidSystemState)
        let backspaceKey: CGKeyCode = 51
        
        for _ in 0..<count {
            if let eventDown = CGEvent(keyboardEventSource: source, virtualKey: backspaceKey, keyDown: true) {
                eventDown.post(tap: .cghidEventTap)
            }
            if let eventUp = CGEvent(keyboardEventSource: source, virtualKey: backspaceKey, keyDown: false) {
                eventUp.post(tap: .cghidEventTap)
            }
            // 2 milliseconds delay ensures the OS event pipeline processes them sequentially
            Thread.sleep(forTimeInterval: 0.002)
        }
    }
    
    private func typeString(_ string: String) {
        let source = CGEventSource(stateID: .hidSystemState)
        let utf16Chars = Array(string.utf16)
        
        if let eventDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) {
            var tempChars = utf16Chars
            eventDown.keyboardSetUnicodeString(stringLength: tempChars.count, unicodeString: &tempChars)
            eventDown.post(tap: .cghidEventTap)
        }
        
        if let eventUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) {
            var tempChars = utf16Chars
            eventUp.keyboardSetUnicodeString(stringLength: tempChars.count, unicodeString: &tempChars)
            eventUp.post(tap: .cghidEventTap)
        }
    }
    
    private func triggerEmojiPicker() {
        let source = CGEventSource(stateID: .hidSystemState)
        let flags: CGEventFlags = [.maskControl, .maskCommand]
        let spaceKey: CGKeyCode = 49 // Space bar is 49 (0x31)
        
        if let keyDown = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: true) {
            keyDown.flags = flags
            keyDown.post(tap: .cghidEventTap)
        }
        
        if let keyUp = CGEvent(keyboardEventSource: source, virtualKey: spaceKey, keyDown: false) {
            keyUp.flags = flags
            keyUp.post(tap: .cghidEventTap)
        }
    }
    
    // Core caret tracking using Accessibility APIs
    private func getCaretScreenPosition() -> CGRect? {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: AnyObject?
        
        let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard error == .success, focusedElement != nil else {
            return nil
        }
        let element = focusedElement as! AXUIElement
        
        var selectedRangeValue: AnyObject?
        let rangeError = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue)
        guard rangeError == .success, let rangeValue = selectedRangeValue else {
            return nil
        }
        
        var boundsValue: AnyObject?
        let boundsError = AXUIElementCopyParameterizedAttributeValue(element, kAXBoundsForRangeParameterizedAttribute as CFString, rangeValue, &boundsValue)
        if boundsError == .success, boundsValue != nil {
            let bounds = boundsValue as! AXValue
            var rect = CGRect.zero
            if AXValueGetValue(bounds, .cgRect, &rect) {
                // Accessibility coordinates are Y-down (origin top-left).
                // Convert to AppKit screen coordinates (origin bottom-left).
                if let mainScreen = NSScreen.screens.first {
                    let screenHeight = mainScreen.frame.size.height
                    rect.origin.y = screenHeight - rect.origin.y - rect.size.height
                }
                return rect
            }
        }
        
        return nil
    }
}
