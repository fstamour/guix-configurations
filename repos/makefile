
GITHUB_REPOS := stumpwm temper

STUMPWM := ~/.config/stumpwm
SYMLINKS := $(STUMPWM)

all: $(GITHUB_REPOS) $(SYMLINKS)

GIT_CLONE_REPO = $@
GIT_CLONE_DIR = $@
$(GITHUB_REPOS):
	git clone git@github.com:fstamour/$(GIT_CLONE_REPO).git $(GIT_CLONE_DIR)

stumpwm: GIT_CLONE_REPO=stumpwm-config

$(STUMPWM): | stumpwm
	ln -s $(abspath stumpwm) $@
