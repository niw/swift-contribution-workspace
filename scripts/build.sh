#!/usr/bin/env bash

set -e

SCCACHE=$(which sccache) || {
  echo "'sccache' is not found."
  echo "'brew install sccache' to install it."
  exit 1
}

export SCCACHE_CACHE_SIZE=50GB

exec ./swift/utils/build-script \
  --cmake-c-launcher "$SCCACHE" \
  --cmake-cxx-launcher "$SCCACHE" \
  "$@"
