#!/usr/bin/env bash

ROOT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null && pwd)
readonly ROOT_PATH

shopt -s nullglob

for git_path in "$ROOT_PATH"/*/.git; do
  git -C "$(dirname "$git_path")" "$@"
done
