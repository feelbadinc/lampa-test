#!/bin/bash
set -euo pipefail
cd _source

BUILD_INDEX="$BUILD_DIR/index.html"

if [ ! -f "$BUILD_INDEX" ]; then
  echo "$BUILD_INDEX not found, exiting"
  exit 1
fi

touch "$BUILD_DIR/.nojekyll"

if ! grep -q "<head>" "$BUILD_INDEX"; then
  echo "$BUILD_INDEX has no <head> tag, skipping"
  exit 0
fi

JS_NOTRACE="$GITHUB_WORKSPACE/.github/scripts/_notrace.js"
INJECT=""

if [ -f "$JS_NOTRACE" ]; then
  echo "Injecting _notrace.js"
  mv "$JS_NOTRACE" "$BUILD_DIR/_notrace.js"
  INJECT="${INJECT}\n    <script src=\"_notrace.js\"></script>"
fi

if [ -f "$GITHUB_WORKSPACE/settings.json" ]; then
  settings=$(jq -c 'if length > 0 then . else empty end' \
    "$GITHUB_WORKSPACE/settings.json" 2>/dev/null || true)

  if [ -n "$settings" ]; then
    echo "Injecting _settings.js"
    printf 'window.lampa_settings = %s;\n' "$settings" \
      > "$BUILD_DIR/_settings.js"
    INJECT="${INJECT}\n    <script src=\"_settings.js\"></script>"
  fi
fi

if [ -z "$INJECT" ]; then
  echo "Nothing to inject, skipping"
  exit 0
fi

sed -i "s|<head>|<head>${INJECT}|" "$BUILD_INDEX"
echo "Injection successful"
