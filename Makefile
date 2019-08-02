SHELL := bash

VERSION_VALUE ?= $(shell git describe --always --dirty --tags 2>/dev/null)
DOCKER_IMAGE_REPO ?= travisci/travis-listener
DOCKER_DEST ?= $(DOCKER_IMAGE_REPO):$(VERSION_VALUE)
QUAY ?= quay.io
QUAY_IMAGE ?= $(QUAY)/$(DOCKER_IMAGE_REPO)

ifdef $$QUAY_ROBOT_HANDLE
	QUAY_ROBOT_HANDLE := $$QUAY_ROBOT_HANDLE
endif
ifdef $$QUAY_ROBOT_TOKEN
	QUAY_ROBOT_TOKEN := $$QUAY_ROBOT_TOKEN
endif
ifndef $$TRAVIS_BRANCH
	TRAVIS_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
endif

DOCKER ?= docker

.PHONY: %
%:
	./script/$@

.PHONY: all
all: clean test

.PHONY: docker-build
docker-build:
	$(DOCKER) build -t $(DOCKER_DEST) .

.PHONY: docker-push
docker-push:
	$(DOCKER) login -u=$(QUAY_ROBOT_HANDLE) -p=$(QUAY_ROBOT_TOKEN) $(QUAY)
	$(DOCKER) tag $(DOCKER_DEST) $(QUAY_IMAGE):$(VERSION_VALUE)
	$(DOCKER) push $(QUAY_IMAGE):$(VERSION_VALUE)

.PHONY: ship
ship: docker-build

ifeq ($(TRAVIS_BRANCH),master)
ship: docker-push
endif
