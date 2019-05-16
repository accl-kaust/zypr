SHELL := /usr/bin/env zsh

VIVADO_PATH = /tools/Xilinx/Vivado/2018.2/bin/vivado

clean:
	rm -rf ./vivado/*
	rm -R ./vivado/.Xil

build:
	proxychains $(VIVADO_PATH) -mode batch -source generate.tcl -nojou -nolog
	
