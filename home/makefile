
GUIX := ~/.config/guix/current/bin/guix
CONF := $(CURDIR)/home-configuration.scm

build:
	$(GUIX) home build $(CONF)

test:
	$(GUIX) home container $(CONF)

.PHONY: home
home:
	$(GUIX) home reconfigure $(CONF)

XSESSION := ~/.xsession
.PHONY: xsession
xsession: $(XSESSION)
$(XSESSION):
	ln -s $(abspath xsession) $@
