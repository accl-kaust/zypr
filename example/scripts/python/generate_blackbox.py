from __future__ import absolute_import
from __future__ import print_function
import sys
import os
import json
import pyverilog.vparser.ast as vast
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

def main():
    for root, dirs, files in os.walk("."):
        path = root.split(os.sep)
        # print((len(path) - 1) * '---', os.path.basename(root))
        for file in files:
            if file.endswith('.json'):           
                # print(root) 
                # print(len(path) * '---', file)
                with open(root+os.sep+file) as json_file:
                    data = json.load(json_file)
                    top_module = data['CELL']['top']
                    print(top_module)
                    port_list = []
                    for module_port in data['CELL']['top']['PORT']:
                        width = data['CELL']['top']['PORT'][module_port]['WIDTH']
                        direction = data['CELL']['top']['PORT'][module_port]['DIRECTION']
                        # print(module_port + " : " + data['MODULE'][top_module]['PORT'][module_port]['DIRECTION'] + " : " + str(data['MODULE'][top_module]['PORT'][module_port]['WIDTH']))
                        print(module_port)
                        if width != 1:
                            width = vast.Width( vast.IntConst(width-1), vast.IntConst('0') )
                            if direction == "input":
                                port_list.append(vast.Ioport(vast.Input(module_port, width=width)))
                            elif direction == "output":
                                port_list.append(vast.Ioport(vast.Output(module_port, width=width)))
                        else:
                            if direction == "input":
                                port_list.append(vast.Ioport(vast.Input(module_port)))
                            elif direction == "output":
                                port_list.append(vast.Ioport(vast.Output(module_port)))
                    print(port_list)
                    json_file.close()
                params = vast.Paramlist('')
                ports = vast.Portlist( port_list )
                ast = vast.ModuleDef(top_module, params, ports, [])
                codegen = ASTCodeGenerator()
                rslt = codegen.visit(ast)
                print("File Name: {}".format(file))
                print("---")
                print(rslt)
                if not os.path.exists('.blackbox'):
                    os.makedirs('.blackbox')
                f = open(".blackbox/{}.v".format(os.path.splitext(file)[0]), "w+")
                f.write(rslt)
                f.close()


if __name__ == '__main__':
    main()