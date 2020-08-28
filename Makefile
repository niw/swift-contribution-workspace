.PHONY: all
all: update

swift:
	git clone --depth=1 https://github.com/apple/swift.git

.PHONY: update
update: swift
	./swift/utils/update-checkout --clone --skip-history

.PHONY: clean
clean:
	./scripts/clean.sh
	rm -f .docker-build

.PHONY: build
build:
	./scripts/build.sh

.PHONY: docker-build
docker-build: .docker-build

.docker-build: docker/Dockerfile
	docker build -t swift docker
	touch .docker-build

.PHONY: docker
docker: docker-build
	docker run --rm -i -t --volume `pwd`:/src --entrypoint bash swift

.PHONY: build-toolchain
build-toolchain:
	./scripts/build-toolchain.sh
