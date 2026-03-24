#!/bin/bash
set -euo pipefail

cd _source

TMPFILE=$(mktemp)
echo "0" > "$TMPFILE"

cleanup() {
  rm -f "$TMPFILE"
  kill -- -${NPM_PID:-0} 2>/dev/null || true
  kill ${INOT_PID:-0} 2>/dev/null || true
}

trap cleanup EXIT
mkdir -p build dest plugins public

setsid npm start 2>/dev/null &
NPM_PID=$!

inotifywait -m -r -e close_write \
  build/ dest/ plugins/ public/ | while IFS= read -r _; do
    date +%s > "$TMPFILE"
done &
INOT_PID=$!

WAIT=0
while [ "$(cat "$TMPFILE")" = "0" ]; do
  sleep 1
  WAIT=$((WAIT + 1))
  if [ "$WAIT" -ge 30 ]; then
    echo "No i/o for 30 seconds, exiting"
    exit 1
  fi
done

while true; do
  LAST=$(cat "$TMPFILE")
  NOW=$(date +%s)
  DIFF=$((NOW - LAST))
  if [ "$DIFF" -gt 1 ]; then
    echo "Stalling for ${DIFF}s"
  fi
  if [ "$DIFF" -ge 5 ]; then
    echo "Build done, exiting Node"
    break
  fi
  sleep 1
done

if [ ! -f "$BUILD_INDEX" ]; then
  echo "$BUILD_INDEX not found, exiting"
  exit 1
fi
