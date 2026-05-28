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
  Source/SwiftmojiApp.swift

echo "🎉 Swiftmoji compiled and bundled successfully!"
echo "📍 App Bundle Location: $(pwd)/${APP_DIR}"
echo "👉 Start using: open ${APP_DIR}"
