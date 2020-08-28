Swift contribution workspace
============================

This repository is a simple workspace include toolings on macOS
for contributing to [Swift](https://github.com/apple/swift) and its related project.

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

To clean,

    $ make clean

which will removes all derived files.

Build corelibs Foundation on Linux
----------------------------------

Use Docker. Current directory is attached to `/src` volume.

    $ make docker
    root@c59f24826e6b:/build# /src/build-swift-corelibs-foundation.sh

Build corelibs Foundation on Windows
------------------------------------

See [how-to documentations](docs/swift_corelibs_foundation_windows_build-ja.md) (currently Japanese only.)

Build without scripts
---------------------

### Without using `sccache`

To build swift, run

    $ ./swift/utils/build-script --release-debuginfo

### With using `sccache`

See <https://github.com/apple/swift/blob/master/docs/DevelopmentTips.md> for the details.

To build swift, run

    $ brew install sccache
    $ export SCCACHE_CACHE_SIZE="50G"
    $ sccache --start-server
    $ ./swift/utils/build-script --release-debuginfo --cmake-c-launcher $(which sccache) --cmake-cxx-launcher $(which sccache)

To see cache,

    $ sccache -s

The cache are available at `~/Library/Caches/Mozilla.sccache`.
