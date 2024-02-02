#!/bin/bash

set -e

DMG_FILE_NAME="SF-Mono.dmg"
FONT_URL="https://devimages-cdn.apple.com/design/resources/download/$DMG_FILE_NAME"
PKG_FILE_NAME="SF Mono Fonts.pkg"

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

# Check if the .pkg file is found
if [ -z "$PKG_FILE" ]; then
    echo "Error: No .pkg file found in the mounted volume."
    # Unmount the volume before exiting
    hdiutil detach "$DMG_VOLUME"
    exit 1
fi

# Copy the .pkg file to the temporary directory
cp "$PKG_FILE" $TEMP_DIR

# Unmount the volume
hdiutil detach "$DMG_VOLUME"

echo ".pkg file copied to the temporary directory."

# Extract the contents of the .pkg file into the 'content' directory
SOURCE_FONT_DIR="$TEMP_DIR/source"
pkgutil --expand-full "$PKG_FILE" $SOURCE_FONT_DIR

echo "Contents of $PKG_FILE extracted into $SOURCE_FONT_DIR."

# Patch the fonts
DEST_FONT_DIR="./fonts"
docker run --rm \
    -v $SOURCE_FONT_DIR:/in:Z \
    -v $DEST_FONT_DIR:/out:Z \
    nerdfonts/patcher \
    --complete # Options

echo "Success: SF Mono fonts patched with Nerd Fonts!"
