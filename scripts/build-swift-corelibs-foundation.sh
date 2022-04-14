#!/usr/bin/env bash

# Built corelibs Foundation and run test using existing toolchain.

set -euo pipefail

# Remove duplicates from toolchain.

for i in Block dispatch CoreFoundation CFURLSessionInterface CFXMLInterface; do
  rm -rf /usr/lib/swift/$i
  rm -rf /usr/lib/swift_static/$i
done
for i in libBlocksRuntime libFoundation libFoundationNetworking libdispatch libswiftDispatch; do
  rm -rf /usr/lib/swift/linux/$i.so
  rm -rf /usr/lib/swift_static/linux/$i.a
done
for i in Dispatch Foundation FoundationNetworking FoundationXML; do
  rm -rf /usr/lib/swift/linux/x86_64/$i.swift*
  rm -rf /usr/lib/swift_static/linux/x86_64/$i.swift*
done

# Build libdispatch

cmake -B /build/libdispatch \
  -D CMAKE_C_COMPILER=clang \
  -D CMAKE_CXX_COMPILER=clang \
  -D ENABLE_SWIFT=YES \
  -G Ninja \
  -S /src/swift-corelibs-libdispatch

ninja -C /build/libdispatch

# Build Foundation without tests

cmake -B /build/foundation \
  -D dispatch_DIR=/build/libdispatch/cmake/modules \
  -D CMAKE_C_COMPILER=clang \
  -G Ninja \
  -S /src/swift-corelibs-foundation

ninja -C /build/foundation

# Build XCTest

cmake -B /build/xctest \
  -D dispatch_DIR=/build/libdispatch/cmake/modules \
  -D Foundation_DIR=/build/foundation/cmake/modules \
  -G Ninja \
  -S /src/swift-corelibs-xctest

ninja -C /build/xctest

# Build Foundationa again with tests

cmake -B /build/foundation \
  -D dispatch_DIR=/build/libdispatch/cmake/modules \
  -D XCTest_DIR=/build/xctest/cmake/modules \
  -D CMAKE_C_COMPILER=clang \
  -G Ninja \
  -D ENABLE_TESTING=YES \
  -S /src/swift-corelibs-foundation

ninja -C /build/foundation

# Run test

ninja -C /build/foundation test
