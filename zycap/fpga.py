import os
import sys
import json
import subprocess
from .utils.tool import tool
import click
import pkg_resources

exists = lambda x:None if x == '' else x

class build(tool):
    def __init__(self, logger, json=None, linux=True):  
        self.logger = logger        
        self.config = self.load_config(json)
        self.root_path = os.getcwd()
        self.device = self.config['project']['project_device']['family']
        self.board_name = self.config['project']['project_device']['name']
        self.board_version = self.config['project']['project_device']['version']
        self.design_name = self.config['design']['design_name']
        self.vivado_path = self.config['config']['config_vivado']['vivado_path']
        self.vivado_version = self.config['config']['config_vivado']['vivado_version']
        self.vivado_params = self.config['config']['config_vivado']['vivado_params']
        self.proxy = exists(self.config['config']['config_vivado']['vivado_proxy'])
        self.petalinux_path = self.config['config']['config_petalinux']['petalinux_path']

    def load_config(self, filename):
        try:
            if filename is None:
                # click.secho('info: {}'.format('Loading default config.'), fg='blue')
                filename = pkg_resources.resource_filename('zycap', 'config/global.json')
            self.logger.info('loading config - {}'.format(filename))
            with open(filename) as j:
                return json.load(j)
        except Exception as e:
            click.secho('error: {}'.format(e), fg='red')
            exit()

    def generate_configs(self):
        pass

    def run(self):
        click.secho('starting ZyCAP build flow...', fg='magenta')
        click.secho('project name: {}'.format(self.design_name), fg='blue')
        click.secho('vivado version: {}'.format(self.vivado_version), fg='blue')
        self.logger.info('loading config')
        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')

        self.source_tools('{}/settings.sh'.format(self.petalinux_path))
        # self.source_tools('{0}/{1}/settings64.sh'.format(self.vivado_path,self.vivado_version))
        click.secho('setup complete [✓]',fg='green')
        # if self.clean:
        #     self.clean_directory()        
        #     click.secho('\rcleaned working directory [✓]',fg='green')











# @click.command()
# @click.option('--config', default=None, help='Specify configuration file.')
# @click.option('--deps', is_flag=True, help='Check ZyCAP build dependencies.')
# @click.option('--clean', is_flag=True, help='Check ZyCAP build dependencies.')
# def cli(config,deps,clean):
#     if deps is False:
#         deps = None
#     z = build(json=config,deps=deps,clean=clean)
#     z.run_tooling()


# if __name__ == '__main__':
#     cli()