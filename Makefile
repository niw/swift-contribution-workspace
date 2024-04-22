# Mostly for casual `python` usages in build scripts.
export PATH := $(abspath bin):$(PATH)

# Use Xcode even if it's not listed yet.
export SKIP_XCODE_VERSION_CHECK := 1

# Use sccache
export SWIFT_USE_SCCACHE := 1
export SCCACHE_CACHE_SIZE := 50GB

.PHONY: all
all: update

swift:
	git clone --depth=1 https://github.com/apple/swift.git

.PHONY: update
update: swift
	swift/utils/update-checkout --clone --skip-history

.PHONY: clean
clean:
	./scripts/git-in-each-repo.sh clean -dffx
	$(RM) -r build
	$(RM) .docker-build

.PHONY: reset
reset:
	./scripts/git-in-each-repo.sh reset --hard
	$(RM) .apply-patches

.PHONY: apply-patches
apply-patches: .apply-patches

.apply-patches:
	./scripts/apply-patches.sh
	touch "$@"

# Simply build Swift.
# See <https://github.com/apple/swift/blob/main/docs/HowToGuides/GettingStarted.md#the-actual-build>.
.PHONY: build
build: apply-patches
	swift/utils/build-script \
		--skip-build-benchmarks \
		--skip-ios \
		--skip-watchos \
		--skip-tvos \
		--swift-darwin-supported-archs "$(shell uname -m)" \
		--release-debuginfo \
		--swift-disable-dead-stripping \
		--bootstrapping=hosttools

# TODO: This is not working.
# Build Toolchain.
# See comments in script first.
.PHONY: build-toolchain
build-toolchain: apply-patches
	scripts/build-toolchain.sh

.PHONY: docker-build
docker-build: .docker-build

.docker-build: docker/Dockerfile
	docker build -t swift docker
	touch "$@"

.PHONY: docker
docker: docker-build
	docker run --rm -i -t --volume `pwd`:/src --entrypoint bash swift
