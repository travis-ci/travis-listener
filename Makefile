SHELL := bash

VERSION_VALUE ?= $(shell git rev-parse --short HEAD 2>/dev/null)
DOCKER_IMAGE_REPO ?= travisci/travis-listener
DOCKER_DEST ?= $(DOCKER_IMAGE_REPO):$(VERSION_VALUE)
QUAY ?= quay.io
QUAY_IMAGE ?= $(QUAY)/$(DOCKER_IMAGE_REPO)
GCR ?= gcr.io/travis-ci-prod-services-1
GCR_IMAGE ?= $(GCR)/$(DOCKER_IMAGE_REPO)

ifdef $$QUAY_ROBOT_HANDLE
	QUAY_ROBOT_HANDLE := $$QUAY_ROBOT_HANDLE
endif
ifdef $$QUAY_ROBOT_TOKEN
	QUAY_ROBOT_TOKEN := $$QUAY_ROBOT_TOKEN
endif
ifdef $$GCR_ACCOUNT_JSON_ENC
	GCR_ACCOUNT_JSON_ENC := $$GCR_ACCOUNT_JSON_ENC
endif
ifndef $$TRAVIS_BRANCH
	TRAVIS_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
endif
ifneq ($(TRAVIS_BRANCH),master)
	BRANCH := $(shell echo "$(TRAVIS_BRANCH)" | sed 's/\//_/')
	VERSION_VALUE := $(VERSION_VALUE)-$(BRANCH)
endif
ifdef $$TRAVIS_PULL_REQUEST
	TRAVIS_PULL_REQUEST := $$TRAVIS_PULL_REQUEST
endif

DOCKER ?= docker

.PHONY: docker-build
docker-build:
	$(DOCKER) build -t $(DOCKER_DEST) .

.PHONY: docker-push
docker-push:
	@echo $(QUAY_ROBOT_TOKEN) | $(DOCKER) login -u $(QUAY_ROBOT_HANDLE) --password-stdin $(QUAY)
	$(shell echo ${GCR_ACCOUNT_JSON_ENC} | openssl enc -d -base64 -A > ./gce-account.json)
	cat ./gce-account.json | $(DOCKER) login -u _json_key --password-stdin https://gcr.io
	rm -f ./gce-account.json
	$(DOCKER) tag $(DOCKER_DEST) $(QUAY_IMAGE):$(VERSION_VALUE)
	$(DOCKER) tag $(DOCKER_DEST) $(GCR_IMAGE):$(VERSION_VALUE)
	$(DOCKER) push $(QUAY_IMAGE):$(VERSION_VALUE)
	$(DOCKER) push $(GCR_IMAGE):$(VERSION_VALUE)

.PHONY: docker-latest
docker-latest:
	$(DOCKER) tag $(DOCKER_DEST) $(QUAY_IMAGE):latest
	$(DOCKER) push $(QUAY_IMAGE):latest

.PHONY: ship
ship: docker-build docker-push

ifeq ($(TRAVIS_BRANCH),master)
ifeq ($(TRAVIS_PULL_REQUEST),false)
ship: docker-latest
endif
endif
