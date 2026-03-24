#!/bin/bash
set -euo pipefail

UPSTREAM_DATE=$(gh api repos/$UPSTREAM_REPO/commits/HEAD \
  --jq '.commit.committer.date' 2>/dev/null || echo "")

if [ -z "$UPSTREAM_DATE" ]; then
  echo "Failed to reach upstream repo, exiting"
  exit 1
fi

UPSTREAM_EPOCH=$(date -d "$UPSTREAM_DATE" +%s)

if [ "${DEPLOY_EPOCH:-0}" -lt "$UPSTREAM_EPOCH" ]; then
  echo "Deployed build is out of date, building"
  echo "skip=false" >> "$GITHUB_OUTPUT"
else
  echo "Deployed build is up to date, skipping"
  echo "skip=true" >> "$GITHUB_OUTPUT"
fi
