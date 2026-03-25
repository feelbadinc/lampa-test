#!/bin/bash
set -euo pipefail

UPSTREAM_DATE=$(gh api repos/$UPSTREAM_REPO/commits/HEAD \
  -H "X-GitHub-Api-Version: $GH_API_VERSION" \
  --jq '.commit.committer.date' 2>/dev/null || echo "")

if [ -z "$UPSTREAM_DATE" ]; then
  echo "Failed to reach upstream repo, exiting"
  exit 1
fi

UPSTREAM_EPOCH=$(date -d "$UPSTREAM_DATE" +%s)

DEPLOY_DATE=$(gh api \
  "repos/$GITHUB_REPOSITORY/deployments?environment=github-pages&per_page=1" \
  -H "X-GitHub-Api-Version: $GH_API_VERSION" \
  --jq '.[0].updated_at' 2>/dev/null || echo "")

echo "$DEPLOY_DATE"

DEPLOY_EPOCH=$(date -d "${DEPLOY_DATE:-@0}" +%s 2>/dev/null || echo 0)

if [[ "$DEPLOY_EPOCH" -lt "$UPSTREAM_EPOCH" || "$FORCE_BUILD" == "true" ]]; then
  echo "last_deploy=$DEPLOY_DATE" >> "$GITHUB_OUTPUT"
  echo "skip_build=false" >> "$GITHUB_OUTPUT"
else
  echo "Deployed build is up to date, skipping"
  echo "skip_build=true" >> "$GITHUB_OUTPUT"
fi
