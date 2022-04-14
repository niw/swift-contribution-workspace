#!/usr/bin/env bash

set -euo pipefail

# Build a Toolchain.
#
# This script is similar `swift/utils/build-toolchain`.
# Use `swift/utils/build-script` to build Toolchain,
# which reads given `swift/utils/build-presets.ini` and expand arguments
# and calls `swift/utils/build-script` again with expanded arguments.

SWIFT_REPO_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/../swift" >/dev/null && pwd)
readonly SWIFT_REPO_PATH

BUNDLE_ID=${BUNDLE_ID:-at.niw}
readonly BUNDLE_ID
SUFFIX=$(date +%Y%m%d)
readonly SUFFIX
NAME=swift-local-$SUFFIX
readonly NAME
DISPLAY_NAME="Swift Local"
readonly DISPLAY_NAME
INSTALL_DESTDIR=$(pwd)/build/toolchain
readonly INSTALL_DESTDIR

mkdir -p "$INSTALL_DESTDIR"

exec "$SWIFT_REPO_PATH/utils/build-script" \
  --preset=buildbot_osx_package,no_test \
  install_destdir="$INSTALL_DESTDIR/install" \
  installable_package="$INSTALL_DESTDIR/$NAME.tar.gz" \
  install_toolchain_dir="/Library/Developer/Toolchains/$NAME.xctoolchain" \
  install_symroot="$INSTALL_DESTDIR/symroot" \
  symbols_package="$INSTALL_DESTDIR/$NAME-symbols.tar.gz" \
  darwin_toolchain_bundle_identifier="$BUNDLE_ID.$NAME" \
  darwin_toolchain_display_name="$DISPLAY_NAME $SUFFIX" \
  darwin_toolchain_display_name_short="$DISPLAY_NAME" \
  darwin_toolchain_xctoolchain_name="$NAME" \
  darwin_toolchain_version="5.0.$SUFFIX" \
  darwin_toolchain_alias=Local \
  "$@"
