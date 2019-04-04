SHELL := /usr/bin/env zsh

VIVADO_PATH

clean:
	rm -rf ./vivado/*
	rm -R ./vivado/.Xil

build:
	/tools/Xilinx/Vivado/2018.2/bin/vivado -mode batch -source generate.tcl
	
