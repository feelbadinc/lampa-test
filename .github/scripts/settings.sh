#!/bin/bash
set -euo pipefail

cd _source

if [ ! -f "$GITHUB_WORKSPACE/settings.json" ]; then
  echo "settings.json not found, skipping"
  exit 0
fi

if [ ! -f "$BUILD_INDEX" ]; then
  echo "$BUILD_INDEX not found, skipping"
  exit 0
fi

if ! grep -q "<body>" "$BUILD_INDEX"; then
  echo "$BUILD_INDEX has no body tag, skipping"
  exit 0
fi

SETTINGS_JS="${BUILD_INDEX%/*}/settings.js"

node -e "
  const { readFileSync, writeFileSync } = require('node:fs');
  let settings, parsed;

  try {
    settings = readFileSync('$GITHUB_WORKSPACE/settings.json', 'utf8');
    parsed = JSON.parse(settings);
  } catch {
    console.error('Failed to parse settings.json');
    process.exit(1);
  }

  if (!Object.keys(parsed).length) process.exit(0);

  writeFileSync(
    '$SETTINGS_JS', \`window.lampa_settings = \${settings.trimEnd()};\`
  );
"

if [ ! -f "$SETTINGS_JS" ]; then
  echo "No settings found, skipping"
  exit 0
fi

INJECTION='<body>\n<script src="settings.js"></script>'
sed -i "s|<body>|${INJECTION}|" "$BUILD_INDEX"
