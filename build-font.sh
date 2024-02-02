#!/bin/bash

set -e

DMG_FILE_NAME="SF-Mono.dmg"
FONT_URL="https://devimages-cdn.apple.com/design/resources/download/$DMG_FILE_NAME"

TEMP_DIR=$(mktemp -d)
DMG_FILE="$TEMP_DIR/$DMG_FILE_NAME"

# Download the base font
curl -o $DMG_FILE $FONT_URL

# Mount the .dmg file
hdiutil attach "$DMG_FILE"

# Find the mounted volume
DMG_VOLUME=/Volumes/SFMonoFonts

# Locate the .pkg file
PKG_FILE=$(find "$DMG_VOLUME" -name "*.pkg" -type f)
echo "Found .pkg file: $PKG_FILE"

# Check if the .pkg file is found
if [ -z "$PKG_FILE" ]; then
    echo "Error: No .pkg file found in the mounted volume."
    # Unmount the volume before exiting
    hdiutil detach "$DMG_VOLUME"
    exit 1
fi

# Extract the contents of the .pkg file
PKG_EXTRACT_PATH="$TEMP_DIR/extract"
pkgutil --expand-full "$PKG_FILE" "$PKG_EXTRACT_PATH"
echo "Contents of $PKG_FILE extracted into $PKG_EXTRACT_PATH"

# Unmount the volume
hdiutil detach "$DMG_VOLUME"

# Copy the font files
EXTRACTED_FONTS_PATH="$PKG_EXTRACT_PATH/SFMonoFonts.pkg/Payload/Library/Fonts"
SOURCE_FONT_DIR="$TEMP_DIR/source"
cp -r "$EXTRACTED_FONTS_PATH" "$SOURCE_FONT_DIR"
echo "Font files copied from $EXTRACTED_FONTS_PATH to $SOURCE_FONT_DIR"

# Patch the fonts
DEST_FONT_DIR="./fonts"
docker run --rm \
    -v $SOURCE_FONT_DIR:/in:Z \
    -v $DEST_FONT_DIR:/out:Z \
    nerdfonts/patcher \
    --complete # Options

echo "Success: SF Mono fonts patched with Nerd Fonts!"
