#!/bin/bash
set -e

APP_NAME="ClaudeUsageBar"
APP="$APP_NAME.app"
INSTALL_DIR="/Applications"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "Building $APP_NAME (release)..."
swift build -c release

echo "Creating .app bundle..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

# Copy binary
cp ".build/release/$APP_NAME" "$APP/Contents/MacOS/"

# Copy resource bundle if exists
BUNDLE=$(find .build/release -name "${APP_NAME}_${APP_NAME}.bundle" -maxdepth 1 | head -1)
if [ -n "$BUNDLE" ]; then
    cp -R "$BUNDLE" "$APP/Contents/Resources/"
fi

# Copy app icon
cp "Resources/AppIcon.icns" "$APP/Contents/Resources/"

# Create Info.plist
VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "1.0.0")
cat > "$APP/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.duaghwns.$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# Ad-hoc code sign so macOS can persistently identify the app (Keychain "Always Allow")
codesign --force --deep -s - "$APP"

echo "Installing to $INSTALL_DIR..."
if [ -d "$INSTALL_DIR/$APP" ]; then
    rm -rf "$INSTALL_DIR/$APP"
fi
cp -R "$APP" "$INSTALL_DIR/"
rm -rf "$APP"

echo ""
echo "Done! $APP_NAME has been installed to $INSTALL_DIR."
echo "You can launch it from Finder, Spotlight, or Launchpad."
