#!/bin/bash
set -e

git fetch origin pages 2>/dev/null \
  && git worktree add --no-checkout _pages pages \
  || git worktree add --orphan -b pages _pages

mv _source/build/web/* _pages/

cp LICENSE _pages/

cat > _pages/README.md << EOF
> Built from https://github.com/$UPSTREAM_REPO
> by https://github.com/$GITHUB_REPOSITORY/tree/master
>
> Last build: $(date -u +%Y-%m-%d)
EOF

cd _pages
git add -A
git commit -m "build $(date -u +%Y%m%d)"
git push origin pages
