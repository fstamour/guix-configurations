
.PHONY: help
help:
	@echo 'Default target is   help'
	@echo ''
	@echo 'Available targets:'
	@echo '  update	guix pull, and update channels.scm'
	@echo '  help  	Show this help.'
	@echo '  setup		Create symlink to channels.scm into ~/.config/guix/'

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
	guix pull --channels=$(CURDIR)/channels-no-commit.scm
	# Saving the channels with the new commits
	guix describe --format=channels > $(CURDIR)/channels.scm
