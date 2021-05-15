SHELL := /bin/bash

##########
########## 1. Configurable Variables
##########

OS_DIST = alpine
SEMVER_TAG = 0.3.1
DOCKER_TAG = ${OS_DIST}-${SEMVER_TAG}
WORK_DIR = $(shell pwd)

##########
########## 2. Non-Configurable Variables
##########

HELP_FUN = \
		%help; \
		while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
		print "usage: make [target]\n\n"; \
		for (sort keys %help) { \
		print "${WHITE}$$_:${RESET}\n"; \
		for (@{$$help{$$_}}) { \
		$$sep = " " x (32 - length $$_->[0]); \
		print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
		}; \
		print "\n"; }

##########
########## 3. Global Targets
##########

.PHONY: help
help: ##@main Show this help
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)

.PHONY: build
build: ##@main Build and tag the docker image
	docker build -t jcacioppo/ansible:${DOCKER_TAG} -f dockerfiles/Dockerfile.${OS_DIST} dockerfiles
.PHONY: pull
pull: ##@main Pull the docker image from Docker Hub
	docker pull jcacioppo/ansible:${DOCKER_TAG}
.PHONY: push
push: ##@main Push the image to Docker Hub
	docker push jcacioppo/ansible:${DOCKER_TAG}
.PHONY: scan
scan: ##@main Scan the image for vulnerabilities
	docker scan jcacioppo/ansible:${DOCKER_TAG}
.PHONY: run
run: ##@main Run the docker container. To change the dir mounted into /root/ansible run `make WORK_DIR=path run`
	docker run \
		--rm \
		--user 0 \
		--net=host \
		-v ${WORK_DIR}:/root/ansible \
		-w /root/ansible \
		--name ansible \
		-it jcacioppo/ansible:${DOCKER_TAG} bash
