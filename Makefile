SHELL := /bin/bash

BUILD_NAMESPACE ?= greenpeaceinternational

SED_MATCH ?= [^a-zA-Z0-9._-]

LOCAL_BACKSTOP_DATA ?= /mypath/to/data

ifeq ($(CIRCLECI),true)
# Configure build variables based on CircleCI environment vars
BUILD_NUM = $(CIRCLE_BUILD_NUM)
BRANCH_NAME ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_BRANCH)")
BUILD_TAG ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_TAG)")
else
# Not in CircleCI environment, try to set sane defaults
BUILD_NUM = local
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD | sed 's/$(SED_MATCH)/-/g')
BUILD_TAG ?= local-tag
endif

dev:
	docker build \
				-t $(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM) \
				.
	docker run --rm \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
		$(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM)

bash:
	docker run --rm -it \
	  -v ${LOCAL_BACKSTOP_DATA}:/app \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
	  --entrypoint=bash \
		$(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM)

dev-history:
	docker run --rm -it \
	  -v ${LOCAL_BACKSTOP_DATA}:/app \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
	  --entrypoint=/src/makehistory.sh \
		$(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM)

dev-compare:
	docker run --rm -it \
	  -v ${LOCAL_PATH}:/app \
	  -e APP_HOSTNAME=${APP_HOSTNAME} \
	  -e APP_HOSTPATH=${APP_HOSTPATH} \
	  --entrypoint=/src/makecomparison.sh \
		$(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM)

build-tag:
	docker build \
				-t $(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM) \
				-t $(BUILD_NAMESPACE)/planet4-backstop:tag-$(BUILD_TAG) \
				-t $(BUILD_NAMESPACE)/planet4-backstop:latest \
				.

build-branch:
	docker build \
				-t $(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM) \
				-t $(BUILD_NAMESPACE)/planet4-backstop:$(BRANCH_NAME) \
				.

push-tag:
	docker push $(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM)
	docker push $(BUILD_NAMESPACE)/planet4-backstop:tag-$(BUILD_TAG)
	docker push $(BUILD_NAMESPACE)/planet4-backstop:latest

push-branch:
	docker push $(BUILD_NAMESPACE)/planet4-backstop:build-$(BUILD_NUM)
	docker push $(BUILD_NAMESPACE)/planet4-backstop:$(BRANCH_NAME)
