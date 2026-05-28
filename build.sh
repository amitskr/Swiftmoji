#!/bin/bash

# Exit immediately if any command fails
set -e

echo "🚀 Starting native build for Swiftmoji..."

# 1. Establish directory path variables
APP_DIR="Swiftmoji.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📂 Creating application bundle directory layout..."
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 2. Copy metadata settings
echo "📝 Packaging Info.plist configurations..."
cp Resources/Info.plist "${CONTENTS_DIR}/Info.plist"
if [ -f Resources/AppIcon.icns ]; then
  echo "🎨 Copying application icon..."
  cp Resources/AppIcon.icns "${RESOURCES_DIR}/AppIcon.icns"
fi

# 3. Locate macOS SDK path
SDK_PATH=$(xcrun --show-sdk-path --sdk macosx)
echo "🛠️ Detected macOS SDK path: ${SDK_PATH}"

# 4. Compile Swift files for arm64 target architecture
echo "🔨 Compiling Swift source files..."
swiftc \
  -O \
  -sdk "${SDK_PATH}" \
  -target arm64-apple-macos11.0 \
  -o "${MACOS_DIR}/Swiftmoji" \
  Source/EmojiDatabase.swift \
  Source/AutocompleteView.swift \
  Source/FloatingPanel.swift \
  Source/KeyboardManager.swift \
  Source/AppDelegate.swift \
  Source/PreferencesView.swift \
  Source/EmojiBrowserView.swift \
  Source/SwiftmojiApp.swift

# 5. Apply ad-hoc code signature to register with TCC (Accessibility) properly
echo "🔏 Applying ad-hoc code signature..."
codesign --force --deep --sign - "${APP_DIR}"

echo "🎉 Swiftmoji compiled and bundled successfully!"
echo "📍 App Bundle Location: $(pwd)/${APP_DIR}"
echo "👉 Start using: open ${APP_DIR}"
