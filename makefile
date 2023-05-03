
HOSTNAME := $(shell hostname)

# TODO The default target should probably be "help".
.PHONY: all
all: channels host homes

.PHONY: home
home:
	$(MAKE) -C home home

.PHONY: channels
channels:
	$(MAKE) -C channels

.PHONY: host
host: $(HOSTNAME)

.PHONY: $(HOSTNAME)
$(HOSTNAME):
	sudo guix system reconfigure hosts/$(HOSTNAME)/config.scm

