from __future__ import absolute_import
from __future__ import print_function
import logging
import sys
import os
import shutil
import xmltodict
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
        logger.error('Missing Global Config - {}'.format(os.getcwd()))
        # print(os.getcwd())
        sys.exit()
    else:
        pass
    for mode in config['design']['design_mode']:
        # print(mode)
        if not os.path.exists('.modes/{}'.format(mode)):
            os.makedirs('.modes/{}'.format(mode))
            os.makedirs('.modes/{}/.checkpoints'.format(mode))
        f = open('.modes/{}/{}'.format(mode,'interface.v'), "w+")
        f.close()
        for mode_configs in config['design']['design_mode'][mode]['configs']:
            # print(mode_configs)
            top_module = config['design']['design_mode'][mode]['configs'][mode_configs]['top_module']
            shutil.copyfile(top_module, '.blackbox/{}'.format(top_module))
            f = open('.blackbox/{}'.format(top_module),"a+")
            for config_variations in config['design']['design_mode'][mode]['configs'][mode_configs]['rtl']:
                # print(config_variations)
                if config_variations != top_module:
                    logger.debug("MODE - {}".format(mode))
                    logger.debug("CONFIG - {}".format(config_variations))
                    if not os.path.exists('.modes/{}/{}'.format(mode,mode_configs)):
                        os.makedirs('.modes/{}/{}'.format(mode,mode_configs))
                        os.makedirs('.modes/{}/{}/.checkpoints'.format(mode,mode_configs))
                    shutil.copyfile(config_variations,'.modes/{}/{}/{}'.format(mode,mode_configs,config_variations))
                    os.system('vhier -y .modes/{1}/{2}/. --top-module {0} --module-files .modes/{1}/{2}/*.v --xml -o .modes/{1}/{2}/hier.json'.format(config['design']['design_mode'][mode]["pr_module"],mode,mode_configs))
                    with open('.modes/{0}/{1}/hier.json'.format(mode,mode_configs),'r+') as f_xml:
                        data = f_xml.read()
                        o = xmltodict.parse(data)
                        logger.debug(json.dumps(o))
                        f_xml.truncate(0)
                        f_xml.seek(0)
                        json.dump(o,f_xml, ensure_ascii=False, indent=4, sort_keys=True)
                        f_xml.close()
                    with open('.blackbox/{}'.format(config_variations), "r") as f_rtl:
                        for line in f_rtl:
                            f.write(line) 
                    f_rtl.close()
            f.close()

if __name__ == '__main__':
    logging.basicConfig(
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        filename='.logs/interface.log',
        level=logging.DEBUG
        )
    logger = logging.getLogger(__name__)
    main()