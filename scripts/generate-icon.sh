#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$PROJECT_ROOT/scripts/AppIcon.svg"
DESTINATION="$PROJECT_ROOT/Resources/Assets.xcassets/AppIcon.appiconset"

if ! command -v magick >/dev/null 2>&1; then
  echo "缺少 ImageMagick，请先执行 brew install imagemagick" >&2
  exit 1
fi

magick -background none "$SOURCE" -resize 16x16 "$DESTINATION/icon_16x16.png"
magick -background none "$SOURCE" -resize 32x32 "$DESTINATION/icon_16x16@2x.png"
magick -background none "$SOURCE" -resize 32x32 "$DESTINATION/icon_32x32.png"
magick -background none "$SOURCE" -resize 64x64 "$DESTINATION/icon_32x32@2x.png"
magick -background none "$SOURCE" -resize 128x128 "$DESTINATION/icon_128x128.png"
magick -background none "$SOURCE" -resize 256x256 "$DESTINATION/icon_128x128@2x.png"
magick -background none "$SOURCE" -resize 256x256 "$DESTINATION/icon_256x256.png"
magick -background none "$SOURCE" -resize 512x512 "$DESTINATION/icon_256x256@2x.png"
magick -background none "$SOURCE" -resize 512x512 "$DESTINATION/icon_512x512.png"
magick -background none "$SOURCE" -resize 1024x1024 "$DESTINATION/icon_512x512@2x.png"
