from edalize import *
import os
work_root = 'build'

print(os.path.relpath('test.tcl', work_root))

exit()

files = [
  {'name' : os.path.relpath('test.tcl', work_root),
   'file_type' : 'tclSource'},
  {'name' : os.path.relpath('build-ps.tcl', work_root),
   'file_type' : 'tclSource'},
  {'name' : os.path.relpath('blinky.v', work_root),
   'file_type' : 'verilogSource'},
  {'name' : os.path.relpath('constraint.xdc', work_root),
   'file_type' : 'xdc'},
]

parameters = {'clk_freq_hz' : {'datatype' : 'int', 'default' : 1000, 'paramtype' : 'vlogparam'},
              'vcd' : {'datatype' : 'bool', 'paramtype' : 'plusarg'}}

tool = 'vivado'

tool_options = {
    'part':'xczu3eg-sbva484-1-e'
}

edam = {
  'files'        : files,
  'name'         : 'blinky_project',
  'parameters'   : parameters,
  'toplevel'     : 'blinky_project_wrapper',
  'tool_options': {'vivado' : tool_options}
}

backend = get_edatool(tool)(edam=edam,
                            work_root=work_root)
try:
  os.makedirs(work_root)
except:
    pass
backend.configure()
# backend.build()
# args = {'vcd' : True}
# backend.run(args)