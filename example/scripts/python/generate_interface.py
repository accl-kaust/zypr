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


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    main()