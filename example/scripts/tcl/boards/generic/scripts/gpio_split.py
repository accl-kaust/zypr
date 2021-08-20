#!/usr/bin/env python
"""
Generates a GPIO MUX for toggling AXIS MUX/DEMUX
"""

from __future__ import print_function

import argparse
import math
from jinja2 import Template

def main():
    parser = argparse.ArgumentParser(description=__doc__.strip())
    parser.add_argument('-p', '--ports',  type=int, default=4, help="number of ports")
    parser.add_argument('-n', '--name',   type=str, help="module name")
    parser.add_argument('-o', '--output', type=str, help="output file name")

    args = parser.parse_args()

    try:
        generate(**args.__dict__)
    except IOError as ex:
        print(ex)
        exit(1)

def generate(ports=4, name=None, output=None):
    n = ports

    if name is None:
        name = "gpio_split_{0}".format(n)

    if output is None:
        output = name + ".v"

    print("Opening file '{0}'...".format(output))

    output_file = open(output, 'w')

    print("Generating {0} port GPIO Split {1}...".format(n, name))

    cn = int(math.ceil(math.log(n, 2)))

    t = Template(u"""/*

Copyright (c) 2020 Alex Bucknall

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

*/

// Language: Verilog 2001

`timescale 1ns / 1ps

/*
 * GPIO {{n}} mux (wrapper)
 */

module {{name}}(

    output enable,
    output drop,
    output [{{n-2}}:0] sel,
    input [{{n}}:0] gpio
    );
    
    assign enable = gpio[0];
    assign drop = gpio[1];
    assign sel [{{n-2}}:0] = gpio[{{n}}:2];

endmodule

""")

    output_file.write(t.render(
        n=n,
        cn=cn,
        name=name
    ))

    print("Done")

if __name__ == "__main__":
    main()

