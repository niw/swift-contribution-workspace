#!/usr/bin/env bash

set -e

for dir in $(find . -mindepth 2 -maxdepth 2 -name '.git'); do
  basedir=$(dirname "$dir")
  pushd "$basedir" >/dev/null
  git clean -dffx
  popd >/dev/null
done

if [[ -d build ]]; then
  rm -rf build
fi
