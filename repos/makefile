# "all" is the default target
.PHONY: all
all: clone link

# target to (re)generate the included makefile
repos.mak: repos.awk repos.tsv
	./$< repos.tsv > $@

include repos.mak

### Quicklisp

QUICKLISP_DIR := ~/quicklisp
QL_LOCAL_PROJECTS_DIR := $(QUICKLISP_DIR)/local-projects

$(QL_LOCAL_PROJECTS_DIR): $(QUICKLISP_DIR)
	mkdir -p $@

$(QUICKLISP_DIR):
	sbcl --noinform \
		--load ./quicklisp.lisp \
		--eval '(quicklisp-quickstart:install)' \
		--eval '(ql:add-to-init-file)'

# "Extra symlinks" that goes into quicklisp's local-projects directory
$(BREEZE_EXTRA): $(QL_LOCAL_PROJECTS_DIR)
