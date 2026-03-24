#!/bin/bash
set -euo pipefail

cd _source

cleanup() {
  [ -n "${NPM_PID:-}" ] || return
  kill -- -$NPM_PID 2>/dev/null || true
}

trap cleanup EXIT
mkdir -p build dest plugins public

setsid npm start 2>/dev/null &
NPM_PID=$!

if ! inotifywait -r -e close_write --timeout 30 \
  build/ dest/ plugins/ public/ > /dev/null 2>&1; then
  echo "No activity after 30 seconds, exiting"
  exit 1
fi

while inotifywait -r -e close_write --timeout 5 \
  build/ dest/ plugins/ public/ > /dev/null 2>&1; do :; done

echo "Build finished"

if [ ! -f "$BUILD_INDEX" ]; then
  echo "$BUILD_INDEX not found, exiting"
  exit 1
fi

sed -i 's|http://|//|g' "$BUILD_INDEX"
