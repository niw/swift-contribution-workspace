#!/usr/bin/env bash

ROOT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)
readonly ROOT_PATH

shopt -s nullglob

for git_path in "$ROOT_PATH"/*/.git; do
  repo_path=$(dirname "$git_path")
  repo_name=$(basename "$repo_path")

  for patch_path in "$ROOT_PATH/patches/$repo_name"/*.patch; do
    echo "Applying $patch_path"
    patch -d "$repo_path" -p1 < "$patch_path"
  done
done
