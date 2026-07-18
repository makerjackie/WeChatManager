#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "用法：scripts/create-dmg.sh <应用路径> <DMG 输出路径>" >&2
  exit 2
fi

APP_PATH="$1"
DMG_PATH="$2"
STAGING_PATH="$(mktemp -d)"
trap 'rm -rf "$STAGING_PATH"' EXIT

/usr/bin/ditto "$APP_PATH" "$STAGING_PATH/微信多开助手.app"
/bin/ln -s /Applications "$STAGING_PATH/应用程序"
/usr/bin/hdiutil create \
  -volname "微信多开助手" \
  -srcfolder "$STAGING_PATH" \
  -ov \
  -format UDZO \
  "$DMG_PATH"
