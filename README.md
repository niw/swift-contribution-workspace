Swift contribution workspace
============================

This repository is a simple workspace include toolings on macOS for
contributing to [Swift](https://github.com/apple/swift) and its related
project.

Usage
-----

Clone `swift` from GitHub.

    $ make swift

This `swift` is cloned out with `--depth=1`. Then, run

    $ make update

to clone all the other repositories, or update them.

To build swift,

    $ make build

It will use `sccache`. See below for the details.

To build toolchain,

    $ make build-toolchain

It will take much longer time than `make build`.

> NOTE: On Apple Silicon and/or macOS 12.3, for now,
> it seems needed to modify preset configuration.
> See inline comments in the build script.

To clean,

    $ make clean

which will removes all derived files.

Build corelibs Foundation on Linux
----------------------------------

Use Docker. Current directory is attached to `/src` volume.
This is very fast because it is using nightly Swift toolchain and not
build Swift itself.

To forcibly update Docker image, delete `.docker-build`.

    $ make docker
    root@c59f24826e6b:/src# /scripts/build-swift-corelibs-foundation.sh

Build corelibs Foundation on Windows
------------------------------------

See [how-to documentations](docs/swift_corelibs_foundation_windows_build-ja.md)
(currently Japanese only.)

Build without scripts
---------------------

### Without using `sccache`

To build swift, run

    $ ./swift/utils/build-script --release-debuginfo

### With using `sccache`

See <https://github.com/apple/swift/blob/master/docs/DevelopmentTips.md>
for the details.

To build swift, run

    $ brew install sccache
    $ export SCCACHE_CACHE_SIZE="50G"
    $ sccache --start-server
    $ ./swift/utils/build-script --sccache --release-debuginfo

To see cache,

    $ sccache -s

The cache are available at `~/Library/Caches/Mozilla.sccache`.

Due to <https://github.com/mozilla/sccache/pull/898>, sccache 0.2.14 and
0.2.15 are not working with Swift build as described in the
<https://github.com/apple/swift/blob/main/docs/HowToGuides/GettingStarted.md#troubleshooting-build-issues>.
You need to build 0.2.16 which includes <https://github.com/mozilla/sccache/pull/959>
from source code as of April 17, 2022.
