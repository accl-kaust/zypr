from __future__ import absolute_import
from __future__ import print_function
import sys
import os
import json
import pyverilog.vparser.ast as vast
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

def extract_pr_cells():
    cell_list = []
    with open('../global_config.json') as json_file:
        data = json.load(json_file)
        for mode in data["design"]["design_mode"]:
            try:
                for each in data["design"]["design_mode"][mode]["pr_cell"]:
                    # make this into a dict and the key becomes the cell and the value the mode associated
                    cell_list.append(each)
            except:
                pass
    json_file.close()
    return cell_list

def main():
    pr_cells = extract_pr_cells()
    print(pr_cells)

    for root, dirs, files in os.walk("."):
        path = root.split(os.sep)
        for file in files:
            if file.endswith('.json'):    
                print(str(root+os.sep+file))       
                with open(root+os.sep+file) as json_file:
                    data = json.load(json_file)
                    top_module = data['CELL']['top']
                    for cell in pr_cells:
                        print('cell:{}'.format(cell))
                        blob = list(find(cell, data))[0]
                        # only need to find a single instance
                        # print(blob)
                        port_list = []
                        try:
                            for module_port in blob[cell]['PORT']:
                                width = blob[cell]['PORT'][module_port]['WIDTH']
                                direction = blob[cell]['PORT'][module_port]['DIRECTION']
                                module = blob[cell]['MODULE']
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
                        # json_file.close()
                            params = vast.Paramlist('')
                            ports = vast.Portlist( port_list )
                            ast = vast.ModuleDef(module, params, ports, [])
                            codegen = ASTCodeGenerator()
                            rslt = codegen.visit(ast)
                            print("File Name: {}".format(module))
                            print("---")
                            print(rslt)
                            if not os.path.exists('.blackbox'):
                                os.makedirs('.blackbox')
                            f = open(".blackbox/{}.v".format(os.path.splitext(module)[0]), "w+")
                            f.write(rslt)
                            f.close()
                        except KeyError as e:
                            print("Skipping IP Core")
                            pass
                           
def find(key, dictionary):
    for k, v in dictionary.items():
        if k == key:
            yield dictionary
        elif isinstance(v, dict):
            for result in find(key, v):
                yield result
        elif isinstance(v, list):
            for d in v:
                if isinstance(d, dict):
                    for result in find(key, d):
                        yield result

def getpath(nested_dict, value, prepath=()):
    for k, v in nested_dict.items():
        path = prepath + (k,)
        if v == value: # found value
            return path
        elif hasattr(v, 'items'): # v is a dict
            p = getpath(v, value, path) # recursive call
            if p is not None:
                return p

if __name__ == '__main__':
    main()