#!/bin/bash

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: <source_dir> <destination_dir>"
    exit 1
fi

SOURCE_FONT_DIR="$1"
DEST_FONT_DIR="$2"

docker run --rm \
    -v $SOURCE_FONT_DIR:/in:Z \
    -v $DEST_FONT_DIR:/out:Z \
    nerdfonts/patcher \
    --complete
