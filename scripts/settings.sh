#!/bin/bash
set -e

node -e "
  const { readFileSync, writeFileSync } = require('node:fs');
  let settings;

  try {
    settings = readFileSync(
      '$GITHUB_WORKSPACE/settings.json', 'utf8'
    );
    JSON.parse(settings);
  } catch {
    console.error('Failed to parse settings.json');
    settings = '{}';
  }
  
  writeFileSync(
    'build/web/settings.js',
    \`window.lampa_settings = \${settings.trimEnd()};\`
  );
"

INJECTION='<body>\n    <script src="settings.js"></script>'
sed -i "s|<body>|${INJECTION}|" build/web/index.html
