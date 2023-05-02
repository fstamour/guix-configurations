
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
	echo $(HOSTNAME)

.PHONY: $(HOSTNAME)
$(HOSTNAME):
	$(MAKE) -C hosts/$(HOSTNAME)

