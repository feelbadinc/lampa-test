#!/bin/bash
set -e

git fetch origin pages 2>/dev/null \
  && git worktree add --no-checkout _pages pages \
  || git worktree add --orphan -b pages _pages

DATE=$(date -u +%Y-%m-%d)

mv _source/build/web/* _pages/
cp LICENSE _pages/

cat > _pages/README.md << EOF
> Built from https://github.com/$UPSTREAM_REPO<br>
> by https://github.com/$GITHUB_REPOSITORY/tree/master
>
> Last build: $DATE
EOF

cd _pages
git add -A
git commit -m "build $DATE"
git push origin pages
