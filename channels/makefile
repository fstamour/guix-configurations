
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

.PHONY: describe
describe:
>>>>>>> 5b369fc (add guix channels, "pin" channels to a specific commit)
	guix describe --format=channels > $(CURDIR)/channels.scm
