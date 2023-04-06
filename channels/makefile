
# Put channels.scm into ~/.config/guix/
~/.config/guix/channels.scm: $(CURDIR)/channels.scm | ~/.config/guix/
	ln -s $< $@

# If guix is already installed, this should already exists...
~/.config/guix/:
	mkdir -p $@
