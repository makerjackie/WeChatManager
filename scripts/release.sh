#!/bin/bash

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "用法：scripts/release.sh <版本号> <构建号>" >&2
  exit 2
fi

VERSION="$1"
BUILD_NUMBER="$2"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_ROOT="$PROJECT_ROOT/build/release"
ARCHIVE_PATH="$BUILD_ROOT/WeChatManager.xcarchive"
EXPORT_PATH="$BUILD_ROOT/export"
APP_PATH="$EXPORT_PATH/WeChatManager.app"
UPDATES_PATH="$BUILD_ROOT/updates"
DMG_PATH="$UPDATES_PATH/WeChatManager.dmg"
SPARKLE_TOOLS="$PROJECT_ROOT/.build/SourcePackages/artifacts/sparkle/Sparkle/bin"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$PROJECT_ROOT/Config/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$PROJECT_ROOT/Config/Info.plist"

cd "$PROJECT_ROOT"
xcodegen generate
xcodebuild test \
  -project WeChatManager.xcodeproj \
  -scheme WeChatManager \
  -destination 'platform=macOS,arch=arm64'

xcodebuild archive \
  -project WeChatManager.xcodeproj \
  -scheme WeChatManager \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  -destination 'generic/platform=macOS' \
  -allowProvisioningUpdates

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$PROJECT_ROOT/Config/ExportOptions.plist" \
  -allowProvisioningUpdates

codesign --verify --deep --strict --verbose=2 "$APP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$BUILD_ROOT/WeChatManager.zip"
asc notarization submit --file "$BUILD_ROOT/WeChatManager.zip" --wait --timeout 1h
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"

mkdir -p "$UPDATES_PATH"
"$PROJECT_ROOT/scripts/create-dmg.sh" "$APP_PATH" "$DMG_PATH"
cp "$PROJECT_ROOT/CHANGELOG.md" "$UPDATES_PATH/WeChatManager.md"
asc notarization submit --file "$DMG_PATH" --wait --timeout 1h
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"
spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG_PATH"
(
  cd "$UPDATES_PATH"
  shasum -a 256 "$(basename "$DMG_PATH")" > "$(basename "$DMG_PATH").sha256"
)

if [ ! -x "$SPARKLE_TOOLS/generate_appcast" ]; then
  xcodebuild -resolvePackageDependencies \
    -project WeChatManager.xcodeproj \
    -scheme WeChatManager \
    -clonedSourcePackagesDirPath .build/SourcePackages
fi

"$SPARKLE_TOOLS/generate_appcast" \
  --download-url-prefix "https://github.com/makerjackie/WeChatManager/releases/download/v$VERSION/" \
  --link "https://github.com/makerjackie/WeChatManager" \
  --embed-release-notes \
  -o "$PROJECT_ROOT/appcast.xml" \
  "$UPDATES_PATH"

echo "发布产物：$DMG_PATH"
echo "Sparkle feed：$PROJECT_ROOT/appcast.xml"
