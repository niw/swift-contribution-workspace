FROM swiftlang/swift:nightly-jammy

RUN apt-get update && apt-get install -y \
    clang \
    cmake \
    git \
    icu-devtools \
    libcurl4-openssl-dev \
    libedit-dev \
    libicu-dev \
    libncurses5-dev \
    libpython2-dev \
    libsqlite3-dev \
    libxml2-dev \
    ninja-build \
    pkg-config \
    python3 \
    rsync \
    swig \
    systemtap-sdt-dev \
    tzdata \
    uuid-dev

RUN mkdir -p /build

VOLUME /src
WORKDIR /src
