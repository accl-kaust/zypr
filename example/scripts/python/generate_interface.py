from __future__ import absolute_import
from __future__ import print_function
import logging
import sys
import os
import json
import pyverilog.vparser.ast as vast
from pyverilog.ast_code_generator.codegen import ASTCodeGenerator

def main():
    if not os.path.exists('.modes'):
        os.makedirs('.modes')
    logger.info('Checking for Global Config')
    try:
        with open('../global_config.json') as json_file:
            config = json.load(json_file)
    except FileNotFoundError:
        logger.error('Missing Global Config')
    else:
        pass
    for mode in config['design']['design_mode']:
        print(mode)
        for mode_interface in config['design']['design_mode'][mode]['interfaces']:
            print(mode_interface)
            for interface in config['design']['design_mode'][mode]['interfaces'][mode_interface]:
                print(interface)



    # for root, dirs, files in os.walk("."):
    #     path = root.split(os.sep)
    #     # print((len(path) - 1) * '---', os.path.basename(root))
    #     for file in files:
    #         if file.endswith('.json'):            
    #             print(len(path) * '---', file)
    #             with open(file) as json_file:
    #                 data = json.load(json_file)
    #                 top_module = data['TOP_MODULE']
    #                 port_list = []
    #                 for module_port in data['MODULE'][top_module]['PORT']:
    #                     width = data['MODULE'][top_module]['PORT'][module_port]['WIDTH']
    #                     direction = data['MODULE'][top_module]['PORT'][module_port]['DIRECTION']
    #                     # print(module_port + " : " + data['MODULE'][top_module]['PORT'][module_port]['DIRECTION'] + " : " + str(data['MODULE'][top_module]['PORT'][module_port]['WIDTH']))
    #                     print(module_port)
    #                     if width is not 1:
    #                         width = vast.Width( vast.IntConst(width-1), vast.IntConst('0') )
    #                         if direction == "input":
    #                             port_list.append(vast.Ioport(vast.Input(module_port, width=width)))
    #                         elif direction == "output":
    #                             port_list.append(vast.Ioport(vast.Output(module_port, width=width)))
    #                     else:
    #                         if direction == "input":
    #                             port_list.append(vast.Ioport(vast.Input(module_port)))
    #                         elif direction == "output":
    #                             port_list.append(vast.Ioport(vast.Output(module_port)))
    #                 print(port_list)
    #             params = vast.Paramlist('')
    #             ports = vast.Portlist( port_list )
    #             ast = vast.ModuleDef("black_box", params, ports, [])
    #             codegen = ASTCodeGenerator()
    #             rslt = codegen.visit(ast)
    #             print(rslt)
    #             if not os.path.exists('.blackbox'):
    #                 os.makedirs('.blackbox')
    #             f = open(".blackbox/{}.v".format(os.path.splitext(file)[0]), "w+")
    #             f.write(rslt)
    #             f.close()


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    main()