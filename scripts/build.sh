#!/bin/bash

TMPFILE=$(mktemp)
echo "0" > "$TMPFILE"

cleanup() {
  rm -f "$TMPFILE"
  kill -- -${NPM_PID:-0} 2>/dev/null
  kill ${INOT_PID:-0} 2>/dev/null
}

trap cleanup EXIT
mkdir -p build dest plugins public

setsid npm start 2>/dev/null &
NPM_PID=$!

inotifywait -m -r -e close_write \
  build/ dest/ plugins/ public/ | while read line; do
    date +%s > "$TMPFILE"
done &
INOT_PID=$!

while [ "$(cat "$TMPFILE")" = "0" ]; do
  sleep 1
done

while true; do
  LAST=$(cat "$TMPFILE")
  NOW=$(date +%s)
  DIFF=$((NOW - LAST))
  if [ "$DIFF" -gt 0 ]; then
    echo "Stalling for ${DIFF}s"
  fi
  if [ "$DIFF" -ge 5 ]; then
    echo "Build done, exiting"
    break
  fi
  sleep 1
done
