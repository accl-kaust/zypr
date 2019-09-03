from __future__ import absolute_import
from __future__ import print_function
import logging
import sys
import os
import shutil
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
        if not os.path.exists('.modes/{}'.format(mode)):
            os.makedirs('.modes/{}'.format(mode))
            os.makedirs('.modes/{}/.checkpoints'.format(mode))
        f = open('.modes/{}/{}'.format(mode,'interface.v'), "w+")
        f.close()
        for mode_configs in config['design']['design_mode'][mode]['configs']:
            print(mode_configs)
            top_module = config['design']['design_mode'][mode]['configs'][mode_configs]['top_module']
            shutil.copyfile(top_module, '.blackbox/{}'.format(top_module))
            f = open('.blackbox/{}'.format(top_module),"a+")
            for config_variations in config['design']['design_mode'][mode]['configs'][mode_configs]['rtl']:
                if config_variations != top_module:
                    with open('.blackbox/{}'.format(config_variations), "r") as f_rtl:
                        for line in f_rtl:
                            f.write(line) 
                    f_rtl.close()
            f.close()



if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    main()