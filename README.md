# ZyCAP 2

ZyCAP 2 is an end-to-end build and runtime tool for Xilinx SoCs.

## Motivation

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
