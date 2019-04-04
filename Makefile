SHELL:=/bin/bash

python_version_full := $(wordlist 2,4,$(subst ., ,$(shell python --version 2>&1)))
python_version_major := $(word 1,${python_version_full})

all:
	@echo ${python_version_major}
	
.PHONY: all

setup:
	@echo "Installing prerequisites...";
	sudo apt install iverilog;
	ifeq ($(python_version_major),3)
		@echo "Python 3 found..."
	else
		set -e
	endif
