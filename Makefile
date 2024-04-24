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
# See comments in script.
.PHONY: build
build: apply-patches
	scripts/build-swift.sh

# The last `cmake -G Ninja` command is for building swift.
# Useful to configure IDE such as CLion.
# See <https://github.com/apple/swift/blob/main/docs/HowToGuides/GettingStarted.md#other-ides-setup>.
.PHONY: cmake-options
cmake-options: apply-patches
	scripts/build-swift.sh --dry-run --reconfigure 2>/dev/null \
	| grep "cmake -G Ninja" \
	| tail -n 1 \
	| sed -E 's/.*cmake -G Ninja //' \
	| sed -E "s/'-D([^=]*)=([^']*)'/\-D\1=\"\2\"/g"

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
