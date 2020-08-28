#!/usr/bin/env bash

set -e

# See `./swift/utils/build-toolchain`
# This is a simple version of it also using `./build.sh` to use `sccache`.

BUNDLE_ID=at.niw
SUFFIX=$(date +%Y%m%d)
NAME=swift-local-$SUFFIX
DISPLAY_NAME="Swift Local"
INSTALL_DESTDIR="$(pwd)/build/toolchain"

mkdir -p "$INSTALL_DESTDIR"

exec ./build.sh \
  --preset=buildbot_osx_package,no_test \
  install_destdir="$INSTALL_DESTDIR/install" \
  install_toolchain_dir="/Library/Developer/Toolchains/$NAME.xctoolchain" \
  installable_package="$INSTALL_DESTDIR/$NAME.tar.gz" \
  install_symroot="$INSTALL_DESTDIR/symroot" \
  symbols_package="$INSTALL_DESTDIR/$NAME-symbols.tar.gz" \
  darwin_toolchain_bundle_identifier="$BUNDLE_ID.$NAME" \
  darwin_toolchain_display_name="$DISPLAY_NAME $SUFFIX" \
  darwin_toolchain_display_name_short="$DISPLAY_NAME" \
  darwin_toolchain_xctoolchain_name="$NAME" \
  darwin_toolchain_version="5.0.$SUFFIX" \
  darwin_toolchain_alias=Local
