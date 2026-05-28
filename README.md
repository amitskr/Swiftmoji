# Swiftmoji 🚀

**Swiftmoji** is a lightweight, responsive, and native macOS menu-bar utility designed for Apple Silicon. It lets you type Slack-style emoji shortcodes (like `:thumbsup:`) in **any application** on your Mac and auto-completes them instantly!

## ✨ Features

- **Global Keystroke Monitoring:** Intercepts shortcode cues natively using macOS Accessibility APIs.
- **Glassmorphic Autocomplete UI:** Displays a gorgeous, dark-themed HUD selector near your text caret that does **not** steal keyboard focus.
- **Natural Keyboard Navigation:** Use arrow keys to navigate matches, and `Enter` or `Tab` to select. Press `Escape` or type a `Space` to dismiss.
- **Closing Colon Completion:** Auto-completes immediately when you type the closing colon (e.g. `:thumbsup:` instantly changes to 👍).
- **Menu Bar Integration:** Runs quietly in the background with a persistent `🚀` menu bar status icon to check permissions or quit.
- **Natively Optimized:** Built in Swift & SwiftUI targeting Apple Silicon (`arm64`) with zero dependencies.

---

## 🛠️ Requirements & Building

- A Mac running Apple Silicon (M1/M2/M3/M4 series).
- Xcode Command Line Tools installed.

### 1. Accept Xcode License
If you haven't compiled developer tools recently, run this in Terminal:
```bash
sudo xcodebuild -license
```

### 2. Compile and Package
Simply run the included build script:
```bash
./build.sh
```
This compiles the Swift files and packages them into a double-clickable macOS bundle: **`Swiftmoji.app`**.

---

## 🚦 Getting Started

1. **Launch the app:**
   ```bash
   open Swiftmoji.app
   ```
2. **Grant Accessibility Permissions:**
   - On launch, macOS will request Accessibility access.
   - Go to **System Settings > Privacy & Security > Accessibility**.
   - Toggle the switch next to **Swiftmoji** to enable it.
3. **Start Typing Emojis:**
   Open any text editor, web browser, or terminal, and type `:th` to see the autocomplete list appear!

---

## 📂 Project Structure

```
Swiftmoji/
├── build.sh                 # High-performance native build script
├── Resources/
│   └── Info.plist           # App configuration settings (runs as background agent)
└── Source/
    ├── SwiftmojiApp.swift   # SwiftUI App Entry Point (@main)
    ├── AppDelegate.swift    # Core status item menu & lifecycle delegation
    ├── FloatingPanel.swift  # Customized HUD borderless panel (non-activating)
    ├── AutocompleteView.swift # SwiftUI list display of matching emojis
    ├── KeyboardManager.swift # Global event tap and backspace/keystroke simulator
    └── EmojiDatabase.swift  # In-memory database mapping 350+ common emojis
```
