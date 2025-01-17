#!/usr/bin/env bash

set -euo pipefail

SWIFT_REPO_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")/../swift" >/dev/null && pwd)
readonly SWIFT_REPO_PATH

# Simply build Swift.
# See <https://github.com/apple/swift/blob/main/docs/HowToGuides/GettingStarted.md#the-actual-build>.
exec "$SWIFT_REPO_PATH/utils/build-script" \
	--skip-build-benchmarks \
	--skip-ios \
	--skip-watchos \
	--skip-tvos \
	--swift-darwin-supported-archs "$(uname -m)" \
	--release-debuginfo \
	--swift-disable-dead-stripping \
	--bootstrapping=hosttools \
  "$@"
