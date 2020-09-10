#!/bin/bash

import os
import sys
import json
import subprocess
import logging
import click
from progress.spinner import Spinner
import pkg_resources

exists = lambda x:None if x == '' else x

class build(object):
    def __init__(self, json=None,deps=None,clean=None,logger=None):  
        self.logger = logger          
        self.config = self.load_config(json)
        self.root_path = os.getcwd()
        self.device = self.config['project']['project_device']['family']
        self.board_name = self.config['project']['project_device']['name']
        self.board_version = self.config['project']['project_device']['version']
        self.design_name = self.config['design']['design_name']
        if deps is None:
            self.check_dependencies = self.config['config']['config_settings']['check_dependencies']
        else:
            self.check_dependencies = deps
        self.vivado_path = self.config['config']['config_vivado']['vivado_path']
        self.vivado_version = self.config['config']['config_vivado']['vivado_version']
        self.vivado_params = self.config['config']['config_vivado']['vivado_params']
        self.proxy = exists(self.config['config']['config_vivado']['vivado_proxy'])
        self.petalinux_path = self.config['config']['config_petalinux']['petalinux_path']
        self.clean = clean

    def loading(self,process):
        spinner = Spinner('Loading ')
        while process.poll() is None:
            spinner.next()

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


    def install_dependencies(self):
        # Python
        # subprocess.check_call([sys.executable, "-m", "pip", "install", "-r","requirements.txt"])
        # Perl (to be deprecated)
        pass

    def install_boards(self):
        pass

    def generate_configs(self):
        pass

    def clean_directory(self):
    # Do some work
        if os.path.isfile("rtl/{}".format(self.design_name)):
            click.secho('error: design name - {} - conflicts with rtl files'.format(self.design_name), fg='red')
            exit()
        s = subprocess.Popen('rm -rf rtl/.* rtl/{} rtl/hd_visual'.format(self.design_name).split(), stdout=subprocess.PIPE)
        self.loading(s)

    def check_tools(self,command):
        process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
        output, error = process.communicate()
        if error is not None:
            click.secho('error [✗]: {}'.format(error), fg='red')
            exit()
        return (output,error)

    def run_tooling(self):
        click.secho('starting ZyCAP build flow...', fg='magenta')
        click.secho('project name: {}'.format(self.design_name), fg='blue')
        click.secho('vivado version: {}'.format(self.vivado_version), fg='blue')
        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')

        if self.check_dependencies:
            click.secho('checking dependencies...', fg='yellow')        
            self.install_dependencies()
        self.check_tools('bash {}/settings.sh'.format(self.petalinux_path))
        self.check_tools('bash {0}/{1}/settings64.sh'.format(self.vivado_path,self.vivado_version))
        click.secho('setup complete [✓]',fg='green')
        if self.clean:
            self.clean_directory()        
            click.secho('\rcleaned working directory [✓]',fg='green')











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