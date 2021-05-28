SHELL := /bin/bash

# ---

# Read default configuration
include config.default
export $(shell sed 's/=.*//' config.default)

# ---

# Image to build
BUILD_IMAGE ?= $(BUILD_NAMESPACE)/$(IMAGE_NAME)
export BUILD_IMAGE

# ---

SED_MATCH ?= [^a-zA-Z0-9._-]

LOCAL_BACKSTOP_DATA ?= /mypath/to/data

ifneq ($(strip $(CIRCLECI)),)
# Configure build variables based on CircleCI environment vars
BUILD_NUM = build-$(CIRCLE_BUILD_NUM)
BUILD_BRANCH ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_BRANCH)")
BUILD_TAG ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_TAG)")
else
# Not in CircleCI environment, try to set sane defaults
BUILD_NUM = build-$(shell uname -n | tr '[:upper:]' '[:lower:]' | sed 's/$(SED_MATCH)/-/g')
BUILD_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD | sed 's/$(SED_MATCH)/-/g')
BUILD_TAG ?= $(shell git tag -l --points-at HEAD | tail -n1 | sed 's/$(SED_MATCH)/-/g')
endif

# If BUILD_TAG is blank there's no tag on this commit
ifeq ($(strip $(BUILD_TAG)),)
# Default to branch name
BUILD_TAG := $(BUILD_BRANCH)
else
# Consider this the new :latest image
# FIXME: implement build tests before tagging with :latest
PUSH_LATEST := true
endif

REVISION_TAG = $(shell git rev-parse --short HEAD)

export BUILD_NUM
export BUILD_BRANCH
export BUILD_TAG

# ---

# Check necessary commands exist
DOCKER := $(shell command -v docker 2> /dev/null)
SHELLCHECK := $(shell command -v shellcheck 2> /dev/null)
SHFMT := $(shell command -v shfmt 2> /dev/null)
YAMLLINT := $(shell command -v yamllint 2> /dev/null)

# ============================================================================

ALL: prepare lint build push

format: format-sh

format-sh:
ifndef SHFMT
	$(error "shfmt is not installed: https://github.com/mvdan/sh")
endif
	@shfmt -i 2 -ci -w .

lint: lint-yaml lint-sh lint-docker

lint-yaml:
ifndef YAMLLINT
	$(error "yamllint is not installed: https://github.com/adrienverge/yamllint")
endif
	@$(YAMLLINT) -d "{extends: default, rules: {line-length: disable}}" .circleci/config.yml

lint-sh:
ifndef SHELLCHECK
	$(error "shellcheck is not installed: https://github.com/koalaman/shellcheck")
endif
ifndef SHFMT
	$(error "shfmt is not installed: https://github.com/mvdan/sh")
endif
	@shfmt -f . | xargs shellcheck -x
	@shfmt -i 2 -ci -d .

lint-docker: Dockerfile
ifndef DOCKER
	$(error "docker is not installed: https://docs.docker.com/install/")
endif
	@docker run --rm -i hadolint/hadolint < Dockerfile

prepare: Dockerfile

Dockerfile:
	envsubst '$${BASE_NAMESPACE},$${BASE_IMAGE},$${BASE_TAG}' < Dockerfile.in > Dockerfile

dev:
	docker build \
		-t $(BUILD_IMAGE):build-$(BUILD_NUM) \
		.
	docker run --rm \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
		$(BUILD_IMAGE):build-$(BUILD_NUM)

bash:
	docker run --rm -it \
	  -v ${LOCAL_BACKSTOP_DATA}:/app \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
	  --entrypoint=bash \
		$(BUILD_IMAGE):build-$(BUILD_NUM)

dev-history:
	docker run --rm -it \
	  -v ${LOCAL_BACKSTOP_DATA}:/app \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
	  --entrypoint=/src/makehistory.sh \
		$(BUILD_IMAGE):build-$(BUILD_NUM)

dev-compare:
	docker run --rm -it \
	  -v ${LOCAL_BACKSTOP_DATA}:/app \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
	  --entrypoint=/src/makecomparison.sh \
		$(BUILD_IMAGE):build-$(BUILD_NUM)

build:
ifndef DOCKER
$(error "docker is not installed: https://docs.docker.com/install/")
endif
	docker build \
		--tag=$(BUILD_IMAGE):$(BUILD_TAG) \
		--tag=$(BUILD_IMAGE):$(BUILD_NUM) \
		--tag=$(BUILD_IMAGE):$(REVISION_TAG) \
		. ; \

push: push-tag push-latest

push-tag:
		docker push $(BUILD_IMAGE):$(BUILD_TAG)
		docker push $(BUILD_IMAGE):$(BUILD_NUM)

push-latest:
		@if [[ "$(PUSH_LATEST)" = "true" ]]; then { \
			docker tag $(BUILD_IMAGE):$(BUILD_NUM) $(BUILD_IMAGE):latest; \
			docker push $(BUILD_IMAGE):latest; \
		}	else { \
			echo "Not tagged.. skipping latest"; \
		} fi
