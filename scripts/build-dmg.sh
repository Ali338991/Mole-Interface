#!/usr/bin/env bash
#
# build-dmg.sh — build a Release .app and package it into a distributable .dmg.
#
# Usage:  ./scripts/build-dmg.sh
# Output: Mole.dmg in the repo root (drag-to-install with an Applications shortcut)
#
# Requirements: macOS + Xcode 16 (command line tools). No extra dependencies.
#
set -euo pipefail

PROJECT="Nebula.xcodeproj"
SCHEME="Nebula"
BUILT_APP_NAME="Nebula"     # the product name Xcode builds (.app)
DIST_APP_NAME="Mole"        # what the app is called in the .dmg
DMG_NAME="Mole"
BUILD_DIR="build"
STAGING="dmg-staging"

cd "$(dirname "$0")/.."

echo "▸ Building Release…"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGNING_ALLOWED=NO \
  build

APP_PATH="$BUILD_DIR/Build/Products/Release/$BUILT_APP_NAME.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "✗ Build product not found at $APP_PATH" >&2
  exit 1
fi

echo "▸ Staging…"
rm -rf "$STAGING" "$DMG_NAME.dmg"
mkdir -p "$STAGING"
cp -R "$APP_PATH" "$STAGING/$DIST_APP_NAME.app"
ln -s /Applications "$STAGING/Applications"

echo "▸ Creating $DMG_NAME.dmg…"
hdiutil create \
  -volname "$DMG_NAME" \
  -srcfolder "$STAGING" \
  -ov -format UDZO \
  "$DMG_NAME.dmg"

rm -rf "$STAGING"
echo "✓ Done — $DMG_NAME.dmg created. Drag $DIST_APP_NAME.app to Applications to install."
