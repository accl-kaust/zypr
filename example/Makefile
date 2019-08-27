SHELL := /usr/bin/env zsh

# VIVADO
#VIVADO_PATH = /tools/Xilinx/Vivado/2018.2/bin/vivado
VIVADO_PATH = /opt/Xilinx/Vivado/2018.2/bin/vivado

# PROXY
PROXY = false

# PYTHON
PYV_FULL := $(wordlist 2,4,$(subst ., ,$(shell python --version 2>&1)))
PYV_MAJOR := $(word 1,${PYV_FULL})

# OUTPUT
ERROR := \033[0;31m
SUCCESS := \033[0;32m
NONE := \033[0m

clean:
	rm -rf ./vivado/*
	rm -R ./vivado/.Xil

python:
ifeq (${PYV_MAJOR}, 3)
	@echo "${SUCCESS}Correct version of Python: 3${NONE}"
else
	@echo "${ERROR}Wrong Python version; Need Python 3${NONE}"
	exit 1 ;
endif
	$(python scripts/python/load_envars.py)
	@echo ${PATH_VIVADO}

vivado:

build: python
	@echo "Starting Vivado"
ifeq (${PROXY}, true)
	@echo "Proxy Enabled" 
	proxychains $(VIVADO_PATH) -mode batch -source generate.tcl -nojou -nolog
else
	$(VIVADO_PATH) -mode batch -source generate.tcl -nojou -nolog
endif

