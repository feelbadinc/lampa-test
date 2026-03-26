#!/bin/bash
set -euo pipefail

(cd _source/$BUILD_DIR && zip -r "$GITHUB_WORKSPACE/release.zip" .)

TAG="lampa-$(date +'%Y-%m-%d')"
CHANGELOG=$(git -C _source --no-pager log --pretty=format:'- `%h` %s')
if [ -n "$CHANGELOG" ]; then
  NOTES="$(printf "**Upstream changes**:\n\n%s" "$CHANGELOG")"
else
  NOTES="No upstream changes."
fi

gh release delete "$TAG" --yes 2>/dev/null || true
gh release create "$TAG" "release.zip" \
  --repo "$GITHUB_REPOSITORY" \
  --notes "$NOTES"
