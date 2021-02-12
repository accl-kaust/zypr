#!/usr/bin/env python
"""
Generates an AXI Stream demux wrapper with the specified number of ports
"""

from __future__ import print_function

import argparse
import math
from jinja2 import Template

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-p', '--ports',  type=int, default=4, help="number of ports")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-i', '--icap',   type=bool, default=True, help="icap enable")
    parser.add_argument('-o', '--output', type=str, help="output file name")
    parser.add_argument('-w', '--width', type=int, default=32, help="data width")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)

def generate(ports=2, name=None, output=None, width=8, icap=True):
    n = ports + 1

    if name is None:
        name = "axis_stream_slave"

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0} port AXI stream demux wrapper {1} with DATA_WIDTH {2}...".format(n, name, width))

    cn = int(math.ceil(math.log(n, 2)))

    t = Template(u"""/*

Copyright (c) 2018 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

Modified 2021 Alex Bucknall

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * AXI4-Stream {{n}} port demux (wrapper)
 */
module {{name}} #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = {{width}},
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = (DATA_WIDTH/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1
)
(
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
    input  wire                  clk,
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *)
    input  wire                  rst,

    /*
     * AXI Stream input
     */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TDATA" *)
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TKEEP" *)
    input  wire [KEEP_WIDTH-1:0] s_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TVALID" *)
    input  wire                  s_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TREADY" *)
    output wire                  s_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TLAST" *)
    input  wire                  s_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TID" *)
    input  wire [ID_WIDTH-1:0]   s_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TDEST" *)
    input  wire [DEST_WIDTH-1:0] s_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 DMA TUSER" *)
    input  wire [USER_WIDTH-1:0] s_axis_tuser,

    /*
     * ICAP Stream outputs
     */
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TDATA" *)
    output wire [DATA_WIDTH-1:0] icap_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TKEEP" *)
    output wire [KEEP_WIDTH-1:0] icap_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TVALID" *)
    output wire                  icap_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TREADY" *)
    input  wire                  icap_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TLAST" *)
    output wire                  icap_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TID" *)
    output wire [ID_WIDTH-1:0]   icap_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TDEST" *)
    output wire [DEST_WIDTH-1:0] icap_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 ICAP TUSER" *)
    output wire [USER_WIDTH-1:0] icap_axis_tuser,

    /*
     * AXI Stream outputs
     */
{%- for p in range(n) %}
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TDATA" *)
    output wire [DATA_WIDTH-1:0] m{{'%02d'%p}}_axis_tdata,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TKEEP" *)
    output wire [KEEP_WIDTH-1:0] m{{'%02d'%p}}_axis_tkeep,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TVALID" *)
    output wire                  m{{'%02d'%p}}_axis_tvalid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TREADY" *)
    input  wire                  m{{'%02d'%p}}_axis_tready,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TLAST" *)
    output wire                  m{{'%02d'%p}}_axis_tlast,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TID" *)
    output wire [ID_WIDTH-1:0]   m{{'%02d'%p}}_axis_tid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TDEST" *)
    output wire [DEST_WIDTH-1:0] m{{'%02d'%p}}_axis_tdest,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_{{'%02d'%p}}_axis TUSER" *)
    output wire [USER_WIDTH-1:0] m{{'%02d'%p}}_axis_tuser,
{% endfor -%}

    /*
     * Control
     */
    input  wire                  enable,
    input  wire                  drop,
    input  wire [{{cn-1}}:0]            sel
);

axis_demux #(
    .M_COUNT({{n}}),
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .ID_WIDTH(ID_WIDTH),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH)
)
axis_demux_inst (
    .clk(clk),
    .rst(rst),
    // AXI inputs
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tid(s_axis_tid),
    .s_axis_tdest(s_axis_tdest),
    .s_axis_tuser(s_axis_tuser),
    // AXI output
    .m_axis_tdata({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tdata{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tdata{% endif %}{% endfor %} }),
    .m_axis_tkeep({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tkeep{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tkeep{% endif %}{% endfor %} }),
    .m_axis_tvalid({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tvalid{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tvalid{% endif %}{% endfor %} }),
    .m_axis_tready({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tready{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tready{% endif %}{% endfor %} }),
    .m_axis_tlast({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tlast{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tlast{% endif %}{% endfor %} }),
    .m_axis_tid({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tid{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tid{% endif %}{% endfor %} }),
    .m_axis_tdest({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tdest{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tdest{% endif %}{% endfor %} }),
    .m_axis_tuser({ {% for p in range(n-1,-1,-1) %}m{{'%02d'%p}}_axis_tuser{% if not loop.last %}, {% endif %}{% if loop.last %}, icap_axis_tuser{% endif %}{% endfor %} }),
    // Control
    .enable(enable),
    .drop(drop),
    .sel(sel)
);

endmodule

""")

    output_file.write(t.render(
        n=n,
        cn=cn,
        name=name,
        width=width
    ))

    print("Done")

# if __name__ == "__main__":
main()

