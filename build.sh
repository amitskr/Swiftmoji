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
mkdir -p scratch/cache

# 2. Copy metadata settings & all icon resources
echo "📝 Packaging Info.plist configurations and icons..."
cp Resources/Info.plist "${CONTENTS_DIR}/Info.plist"
if [ -d "Resources" ]; then
  echo "🎨 Copying application resources, status bar icons, and assets..."
  cp -R Resources/* "${RESOURCES_DIR}/" || true
fi

# 3. Locate macOS SDK path
SDK_PATH=$(xcrun --show-sdk-path --sdk macosx)
echo "🛠️ Detected macOS SDK path: ${SDK_PATH}"

# 4. Compile Swift files for arm64 target architecture
echo "🔨 Compiling Swift source files..."
swiftc \
  -O \
  -module-cache-path scratch/cache \
  -sdk "${SDK_PATH}" \
  -target arm64-apple-macos11.0 \
  -o "${MACOS_DIR}/Swiftmoji" \
  Source/EmojiDatabase.swift \
  Source/GifService.swift \
  Source/AnimatedGIFView.swift \
  Source/AutocompleteView.swift \
  Source/FloatingPanel.swift \
  Source/KeyboardManager.swift \
  Source/AppDelegate.swift \
  Source/PreferencesView.swift \
  Source/EmojiBrowserView.swift \
  Source/SwiftmojiApp.swift

# 5. Apply code signature with persistent developer identity to preserve TCC accessibility across rebuilds
echo "🔏 Applying code signature..."
if security find-identity -v -p codesigning | grep -q "Swiftmoji Developer"; then
  echo "✅ Signing with persistent 'Swiftmoji Developer' identity (preserves TCC accessibility across rebuilds)..."
  codesign --force --deep --sign "Swiftmoji Developer" "${APP_DIR}"
else
  echo "⚠️ Fallback: applying ad-hoc code signature..."
  codesign --force --deep --sign - "${APP_DIR}"
fi

# 6. Deploy to Applications folder and unregister local copy from Launch Services
if [ -w "/Applications" ] && [ -z "${SKIP_DEPLOY}" ]; then
  echo "🚀 Deploying to /Applications/Swiftmoji.app..."
  rm -rf /Applications/Swiftmoji.app || true
  cp -R "${APP_DIR}" /Applications/Swiftmoji.app || true
  
  echo "🧹 Unregistering local build copy from Launch Services..."
  /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -u "$(pwd)/${APP_DIR}" || true
  /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f /Applications/Swiftmoji.app || true
  echo "📍 Deployed App Location: /Applications/Swiftmoji.app"
else
  echo "ℹ️ Note: /Applications is not writable or deploy skipped. Local bundle ready at $(pwd)/${APP_DIR}"
fi

echo "🎉 Swiftmoji compiled, bundled, and deployed successfully!"
echo "📍 Deployed App Location: /Applications/Swiftmoji.app"
echo "👉 Start using: open /Applications/Swiftmoji.app"
