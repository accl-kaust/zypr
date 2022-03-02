# ZyCAP 2

ZyCAP 2 is an end-to-end build and runtime tool for Xilinx SoCs.

## Motivation

Partial reconfiguration (PR) is a key enabler to the design and development of adaptive systems on modern Field Programmable Gate Array (FPGA) Systems-on-Chip (SoCs), allowing hardware to be adapted dynamically at runtime.
Vendor supported PR infrastructure is performance limited and blocking, drivers entail complex memory management, and software/hardware design requires bespoke knowledge of the underlying hardware.
This project presents a complete end-to-end framework that provides high performance reconfiguration of hardware from within a software abstraction in the Linux userspace, automating the process of building PR applications, with support for the Xilinx Zynq and Zynq UltraScale+ architectures, aimed at enabling non-expert application designers to leverage PR for edge applications.
We compare this framework against traditional vendor tooling for PR management as well as recent open source tools that support PR under Linux.
The framework provides a high performance runtime along with low overhead for its provided abstractions.
We introduce improvements to our previous work, increasing the provisioning throughput for PR bitstreams on the Zynq Ultrascale+ by 2× and 5.4× compared to current the vendor runtime, FPGA Manager.

## Requirements

- Xilinx Vivado/Vitis (tested with 2019.2)
- Xilinx PetaLinux (tested with 2019.2)
- Docker (v20.10.7+)

## Setup

```bash
git clone git@github.com:warclab/zycap2.git --recursive
cd zycap2
pip install -e . dependencies
cd zycap/interfacer
pip install -e .
```
