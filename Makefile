# The purpose of this Makefile is to help remembering commands
#
# Run `make help` for available makes and parameters


# https://blog.mindlessness.life/makefile/2019/11/17/the-language-agnostic-all-purpose-incredible-makefile.html
# '- cmd' will ignore errors
# '@cmd' will not output command

help:
	@echo ''
	@echo -e 'usage: \e[1mmake <target> image_version=<version> [registry_login=<registry_login>] [registry_token=<registry_token>]\e[0m'
	@echo ''
	@echo Make targets:
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m    make \1\\x1b[m:\2/' | column -c2 -t -s :)"
	@echo ''

all: help

# Two flavors of variables:
#     - recursive (use =) - only looks for the variables when the command is used, not when it’s defined.
#     - simply expanded (use :=) - like normal imperative programming – only those defined so far get expanded
#     - ?= only sets variables if they have not yet been set
#     - != can be used to execute a shell script and set a variable to its output
docker_cmd != test -x /usr/bin/podman && echo podman || echo docker
registry_fqdn := ghcr.io
build_date != date -u +'%Y%m%d_%H%M'
git_commit_sha_short != git rev-parse --short HEAD
SHELL := /bin/bash
OS=$(shell uname | tr '[A-Z]' '[a-z]')

check_image_version:
ifndef image_version
	$(error Missing image version. Check 'make help')
endif

check_registry_login:
ifndef registry_login
	$(error Missing registry login. Check 'make help')
endif

check_registry_token:
ifndef registry_token
	$(error Missing registry token. Check 'make help')
endif


.make.puppetserver-build: check_image_version
	# pushd image; ${docker_cmd} build -t alexfouche/puppetserver:${image_version}.${build_date}.${git_commit_sha_short} --build-arg VERSION_IMAGE=${image_version} --build-arg BUILD_DATE=`date -u +'%Y-%m-%dT%H:%M:%SZ'` . ; popd
	pushd image; ${docker_cmd} build -t alexfouche/puppetserver:${image_version} --build-arg VERSION_IMAGE=${image_version} --build-arg BUILD_DATE=`date -u +'%Y-%m-%dT%H:%M:%SZ'` . ; popd

	# ${docker_cmd} tag alexfouche/puppetserver:${image_version} alexfouche/puppetserver:latest

	# touch .make.puppetserver-build

puppetserver-build: .make.puppetserver-build  ## Build Puppetserver image

.make.puppetserver-push: check_image_version check_registry_login check_registry_token
	@version=`${docker_cmd} image list alexfouche/puppetserver:* --format "{{.Tag}}" | sort -n | tail -1` ;\
	version=${image_version} ;\
	${docker_cmd} login "${registry_fqdn}" -u "${registry_login}" -p "${registry_token}" ;\
	${docker_cmd} tag alexfouche/puppetserver:$$version "${registry_fqdn}"/alexfouche/puppetserver:$$version ;\
	echo ${docker_cmd} push "${registry_fqdn}"/alexfouche/puppetserver:$$version ;\
	${docker_cmd} push "${registry_fqdn}"/alexfouche/puppetserver:$$version

puppetserver-push: .make.puppetserver-build .make.puppetserver-push  ## push lastly built container image Puppetserver to registry


clean:  # Clean some remnant files
	- rm .make.* 2>/dev/null || true
	- rm .rerun.json 2>/dev/null  || true  # Created by Bolt
	- rm -rf packer-* || true

line_blue:
	@echo -e "\e[44m#########################################################################################################################################################\e[0m"

line_green:
	@echo -e "\e[42m#########################################################################################################################################################\e[0m"

line_pink:
	@echo -e "\e[45m#########################################################################################################################################################\e[0m"

line_red:
	@echo -e "\e[41m#########################################################################################################################################################\e[0m"


# any prerequisites of .PHONY target are always determined to be out-of-date, and will be always be run.
.PHONY: all help clean logs

.DEFAULT_GOAL := help

# some_other_thing: .make.some_other_thing

# .make.some_other_thing: .make.prerequisite_thing
#     do_something
#     touch .make.some_other_thing
