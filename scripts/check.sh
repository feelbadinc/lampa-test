#!/bin/bash
set -e

LAMPA_DATE=$(gh api repos/$UPSTREAM_REPO/commits/HEAD \
  --jq '.commit.committer.date' 2>/dev/null)

if [ -z "$LAMPA_DATE" ]; then
  echo "Failed to reach upstream repo"
  exit 1
fi

PAGES_DATE=$(gh api repos/$GITHUB_REPOSITORY/commits/pages \
  --jq '.commit.committer.date' 2>/dev/null || echo "")

if [ -z "$PAGES_DATE" ] || [[ "$LAMPA_DATE" > "$PAGES_DATE" ]]; then
  echo "Last build is out of date, building"
  echo "skip=false" >> "$GITHUB_OUTPUT"
else
  echo "Last build is up to date, skipping"
  echo "skip=true" >> "$GITHUB_OUTPUT"
fi
