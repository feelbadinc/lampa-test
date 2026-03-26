#!/bin/bash
set -euo pipefail

if [ ! -d "_source/$BUILD_DIR" ]; then
  echo "Build directory $BUILD_DIR not found, exiting"
  exit 1
fi

cd "_source/$BUILD_DIR"

INDEX_FILE=$(find . -maxdepth 1 -iname "index.*" -type f | head -1)

if [ -z "$INDEX_FILE" ]; then
  echo "No index file found in $BUILD_DIR, exiting"
  exit 1
fi

touch .nojekyll
rm Dockerfile
rm README.md

if ! grep -q "<head>" "$INDEX_FILE"; then
  echo "$INDEX_FILE in $BUILD_DIR has no <head> tag, skipping"
  exit 0
fi

JS_NOTRACE="$GITHUB_WORKSPACE/.github/scripts/_notrace.js"
INJECT=""

if [ -f "$JS_NOTRACE" ]; then
  NOTRACE_NAME="$(openssl rand -hex 2).js"
  echo "Injecting _notrace.js"
  mv "$JS_NOTRACE" "$NOTRACE_NAME"
  INJECT="${INJECT}\n    <script src=\"$NOTRACE_NAME\"></script>"
fi

if [ -f "$GITHUB_WORKSPACE/settings.json" ]; then
  settings=$(jq -c 'if length > 0 then . else empty end' \
    "$GITHUB_WORKSPACE/settings.json" 2>/dev/null || true)

  if [ -n "$settings" ]; then
    SETTINGS_NAME="$(openssl rand -hex 2).js"
    echo "Injecting _settings.js"
    printf 'window.lampa_settings = %s;\n' "$settings" > "$SETTINGS_NAME"
    INJECT="${INJECT}\n    <script src=\"$SETTINGS_NAME\"></script>"
  fi
fi

if [ -z "$INJECT" ]; then
  echo "Nothing to inject, skipping"
  exit 0
fi

sed -i "s|<head>|<head>${INJECT}|" "$INDEX_FILE"
echo "Injection successful"
