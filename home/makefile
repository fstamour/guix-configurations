
CONF := $(CURDIR)/home-configuration.scm

test:
	guix home container $(CONF)

.PHONY: home
home:
	guix home reconfigure $(CONF)

XSESSION := ~/.xsession
.PHONY: xsession
xsession: $(XSESSION)
$(XSESSION):
	ln -s $(abspath xsession) $@
