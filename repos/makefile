# "all" is the default target
.PHONY: all
all: clone link

# target to (re)generate the included makefile
repos.mak: repos.awk repos.tsv
	./$< repos.tsv > $@

include repos.mak
