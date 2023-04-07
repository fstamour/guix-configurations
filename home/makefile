
CONF := $(CURDIR)/home-configuration.scm

test:
	guix home container $(CONF)

.PHONY: home
home:
	guix home reconfigure $(CONF)
