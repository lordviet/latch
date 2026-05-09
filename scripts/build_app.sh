#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/ClipboardLatch.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
PACKAGE_DIR="$ROOT_DIR/ClipboardLatch"
EXECUTABLE="$PACKAGE_DIR/.build/release/ClipboardLatch"

mkdir -p "$ROOT_DIR/dist"

env \
  CLANG_MODULE_CACHE_PATH="$PACKAGE_DIR/.build/ModuleCache" \
  SWIFTPM_MODULECACHE_OVERRIDE="$PACKAGE_DIR/.build/ModuleCache" \
  HOME="$PACKAGE_DIR" \
  swift build -c release --package-path "$PACKAGE_DIR"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

cp "$EXECUTABLE" "$MACOS_DIR/ClipboardLatch"
cp "$ROOT_DIR/ClipboardLatch/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
printf 'APPL????' > "$CONTENTS_DIR/PkgInfo"

codesign --force --sign - "$APP_DIR" >/dev/null

echo "Built $APP_DIR"

