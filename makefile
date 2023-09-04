# This makefile assumes some environment variables are set (see
# .envrc).

######################################################################
### Bunch of variables

HOSTNAME := $(or $(HOSTNAME),$(shell hostname))
HOSTS := $(shell awk -F/ '/%hosts\// { print $$2 }' $(CURDIR)/modules/fstamour/system.scm)

BUILD_HOSTS := $(foreach host,$(HOSTS),build-host-$(host))

# a.k.a _fun_
define newline


endef

######################################################################
### Support targets

.PHONY: help
help:
	@echo $$'Default target is:     help'
	@echo $$''
	@echo $$'Available targets:'
	@echo $$'  host                 reconfigure the current host'
	@echo $$'  build-host           build the current host'
	@echo $$'  build-host-<HOST>    Build a specific host Where <HOST> is one of: $(foreach host,$(HOSTS),\n    - $(host))'
	@echo $$'  home                 Reconfigure guix home.'
	@echo $$'  home-build           Build guix home.'
	@echo $$'  update               guix pull, and update channels.scm'
	@echo $$'  setup                Create symlink to channels.scm into ~/.config/guix/'
	@echo $$'  help                 Show this help.'

.PHONY: all
all: setup $(BUILD_HOSTS) home-build

.PHONY: build
build: $(BUILD_HOSTS) home-build

######################################################################
### Home

.PHONY: home
home:
	./home reconfigure

.PHONY: home-build
home-build:
	./home build

######################################################################
### Hosts (systems)

.PHONY: host
host: $(HOSTNAME)

.PHONY: $(BUILD_HOSTS)
$(BUILD_HOSTS):
	host=$(@:build-host-%=%) ./system build

.PHONY: $(HOSTS)
$(HOSTS):
	./system $@ reconfigure

######################################################################
### Channels

.PHONY: setup
setup: ~/.config/guix/channels.scm

# Put channels.scm into ~/.config/guix/
~/.config/guix/channels.scm: | $(CURDIR)/channels.scm ~/.config/guix/
	ln -s $(CURDIR)/channels.scm $@

# If guix is already installed, this should already exists...
~/.config/guix/:
	mkdir -p $@

# Target to update the commits in channels.scm
.PHONY: update
update:
	# Pulling a new commit of the channels
	$(GUIX) pull --channels=$(CURDIR)/channels-no-commit.scm
	# Saving the channels with the new commits
	$(GUIX) describe --format=channels > $(CURDIR)/channels.scm

# TODO use this to update the system-wide (root) profile:
# sudo -i $(GUIX) pull -C /home/fstamour/.config/guix/channels.scm

######################################################################
### Profiles

# TODO make a directory for profiles, probably
lisp-profile/:
	guix install sbcl-slime-swank sbcl-slynk sbcl-breeze -p lisp-profile
