.PHONY: all
all: update

swift:
	git clone --depth=1 https://github.com/apple/swift.git

.PHONY: update
update: swift
	./swift/utils/update-checkout --clone --skip-history

.PHONY: clean
clean:
	./clean.sh

.PHONY: build
build:
	./build.sh

.PHONY: build-toolchain
build-toolchain:
	./build-toolchain.sh
