#!/bin/bash

if [ -n "$LAST_DEPLOY" ]; then
  git clone --shallow-since="$LAST_DEPLOY" \
    https://github.com/$UPSTREAM_REPO _source
else
  git clone --depth=1 \
    https://github.com/$UPSTREAM_REPO _source
fi
