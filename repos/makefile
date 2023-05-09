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
	mkdir $@

$(QUICKLISP_DIR):
	@echo "\"$@\" doesn't exists." >&2
	@echo "Please install quicklisp." >&2
	@exit 1

# "Extra symlinks" that goes into quicklisp's local-projects directory
$(BREEZE_EXTRA): $(QL_LOCAL_PROJECTS_DIR)
