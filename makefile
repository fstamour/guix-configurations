# This makefile assumes some environment variables are set (see
# .envrc).

######################################################################
### Channels

# Create symlink to channels.scm into ~/.config/guix/'
.PHONY: setup
setup: ~/.config/guix/channels.scm

# Put channels.scm into ~/.config/guix/
~/.config/guix/channels.scm: | $(CURDIR)/channels.scm ~/.config/guix/
	ln -s $(CURDIR)/channels.scm $@

# If guix is already installed, this should already exists...
~/.config/guix/:
	mkdir -p $@

# It's worth noting that I try to keep multiple systems on the exact
# same commit of multiple channels, to avoid re-downloading and
# re-compiling too much stuff (especially on my poor old laptop).
#
# https://guix.gnu.org/manual/en/html_node/Upgrading-Guix.html
#
# TODO find better names for theses targets (update and pull)
#
# Here's part of the process (might be worth a diagram):
# 1. bump channels.scm (using channels-no-commit.scm)
# 2. commit & push
# 3. (on another computer) git pull
# 4. make pull

# Target to update the commits in channels.scm
.PHONY: update
update:
	# Pulling a new commit of the channels
	./guix pull --channels=$(CURDIR)/channels-no-commit.scm
	# Saving the channels with the new commits
	./guix describe --format=channels > $(CURDIR)/channels.scm
	# TODO use this to update the system-wide (root) profile:
	# sudo -i $(CURDIR)/guix pull -C ~/.config/guix/channels.scm
	# Update the home profile:
	# make home

######################################################################
### Profiles

# TODO make a directory for profiles, probably
lisp-profile/:
	guix install sbcl-slime-swank sbcl-slynk sbcl-breeze -p lisp-profile

######################################################################
### Trying to build specific packages

sbcl-cache-cache: sbcl-simpbin
cache-cache: sbcl-simpbin
PACKAGES := cl-simpbin ecl-simpbin sbcl-simpbin \
	cl-breeze ecl-breeze sbcl-breeze \
	cl-cache-cache ecl-cache-cache sbcl-cache-cache cache-cache \
	stumpwm-with-swank

.PHONY: all-packages
all-packages: ${PACKAGES}

${PACKAGES}:
	./guix build $@
