#!/bin/bash

# Exit immediately on error
set -e

echo "🚀 Starting Swiftmoji Distribution Packaging..."

PROJECT_DIR="$(pwd)"
BUILD_DIR="${PROJECT_DIR}/Dist/build"
OUTPUT_DIR="${PROJECT_DIR}/Dist"
APP_NAME="Swiftmoji"
DMG_NAME="${APP_NAME}.dmg"
ZIP_NAME="${APP_NAME}-macOS.zip"

# 1. Clean previous distribution output
rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"
mkdir -p "${BUILD_DIR}"

# 2. Run the main build script to produce a clean signed Swiftmoji.app
echo "🔨 Compiling and packaging latest release binary..."
./build.sh

# 3. Stage the Application for DMG Creation
echo "📦 Staging disk image contents..."
STAGE_DIR="${BUILD_DIR}/dmg_stage"
mkdir -p "${STAGE_DIR}"

# Copy application bundle preserving all permissions and attributes
cp -R "Swiftmoji.app" "${STAGE_DIR}/${APP_NAME}.app"

# Create symlink to /Applications for standard Mac drag-and-drop installer
ln -s /Applications "${STAGE_DIR}/Applications"

# Add friendly quick start text for users
cat << 'EOF' > "${STAGE_DIR}/Instructions.txt"
Welcome to Swiftmoji for macOS!

How to Install:
1. Drag "Swiftmoji.app" into the "Applications" folder.
2. Open Swiftmoji from your Applications folder or Spotlight (Cmd+Space).
3. On first launch, follow the prompt to enable Accessibility in:
   System Settings > Privacy & Security > Accessibility
4. Start typing your trigger (e.g. \\dance or \\coffee) in any app!

Enjoy expressiveness everywhere!
EOF

# 4. Generate Compressed DMG Disk Image (.dmg)
echo "💿 Generating Apple Disk Image (${DMG_NAME})..."
DMG_PATH="${OUTPUT_DIR}/${DMG_NAME}"
rm -f "${DMG_PATH}"

hdiutil create \
  -volname "${APP_NAME}" \
  -srcfolder "${STAGE_DIR}" \
  -ov \
  -format UDZO \
  "${DMG_PATH}"

# 5. Generate Universal ZIP Archive (.zip)
echo "🗜️ Generating ZIP Archive (${ZIP_NAME})..."
ZIP_PATH="${OUTPUT_DIR}/${ZIP_NAME}"
ditto -c -k --sequesterRsrc --keepParent "Swiftmoji.app" "${ZIP_PATH}"

# 6. Generate SHA-256 Checksums for Website Download Integrity
echo "🔒 Computing SHA256 checksums..."
cd "${OUTPUT_DIR}"
shasum -a 256 "${DMG_NAME}" "${ZIP_NAME}" > SHA256SUMS.txt
cd "${PROJECT_DIR}"

# 7. Clean temporary build staging
rm -rf "${BUILD_DIR}"

echo ""
echo "========================================================"
echo "🎉 Distribution files created successfully!"
echo "========================================================"
echo "📁 Downloadable files ready in: ${OUTPUT_DIR}"
echo "   1. ${DMG_PATH} (Recommended for Website Download)"
echo "   2. ${ZIP_PATH} (Standard ZIP Archive)"
echo "   3. ${OUTPUT_DIR}/SHA256SUMS.txt"
echo "========================================================"
