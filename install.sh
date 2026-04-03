#!/bin/bash
set -e

echo ""
echo "  ╔═══════════════════════════════╗"
echo "  ║     Installing Adept...       ║"
echo "  ╚═══════════════════════════════╝"
echo ""

# Detect architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  DMG_FILE="Adept-arm64.dmg"
  echo "  Detected: Apple Silicon (M-series)"
else
  DMG_FILE="Adept-x64.dmg"
  echo "  Detected: Intel Mac"
fi

BASE_URL="https://github.com/azurashay/adept-releases/releases/latest/download"
DMG_PATH="/tmp/$DMG_FILE"

echo "  Downloading $DMG_FILE..."
curl -fL "$BASE_URL/$DMG_FILE" -o "$DMG_PATH"

echo "  Mounting installer..."
MOUNT_DIR=$(hdiutil attach "$DMG_PATH" -nobrowse | grep -o '/Volumes/.*' | head -1)

if [ -z "$MOUNT_DIR" ]; then
  echo "  Error: Could not mount DMG"
  exit 1
fi

echo "  Installing to Applications..."
if [ -d /Applications/Adept.app ]; then
  echo "  Updating existing installation..."
  rm -rf /Applications/Adept.app
fi
cp -R "$MOUNT_DIR/Adept.app" /Applications/

echo "  Cleaning up..."
hdiutil detach "$MOUNT_DIR" -quiet 2>/dev/null || true
rm -f "$DMG_PATH"

# Remove quarantine flag — this skips Gatekeeper
xattr -rd com.apple.quarantine /Applications/Adept.app 2>/dev/null || true

echo ""
echo "  ✓ Adept installed!"
echo ""
echo "  Opening Adept..."
open /Applications/Adept.app

echo ""
echo "  Next: Grant Screen Recording permission when prompted."
echo "  Go to System Settings → Privacy → Screen & System Audio Recording → toggle Adept on"
echo ""
