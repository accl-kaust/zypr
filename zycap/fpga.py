import os
import sys
import json
import glob
import subprocess
from .utils.tool import Tool
import click
from pathlib import Path
import pkg_resources

class Build(Tool):
    def __init__(self, logger, json=None, linux=True):  
        self.logger = logger        
        self.config = self.load_config(json)
        self.config['filename'] = json
        self.root_path = Path.cwd()
        self.device = self.config['project']['project_device']['family']
        self.board_name = self.config['project']['project_device']['name']
        self.board_version = self.config['project']['project_device']['version']
        self.design_name = self.config['design']['design_name']
        self.vivado_path = self.config['config']['config_vivado']['vivado_path']
        self.xilinx_version = self.config['config']['config_xilinx']['xilinx_version']
        self.vivado_params = self.config['config']['config_vivado']['vivado_params']
        self.proxy = Tool.exists(self.config['config']['config_xilinx']['xilinx_proxy'])
        self.petalinux_path = self.config['config']['config_petalinux']['petalinux_path']

    def generate_configs(self):
        pass

    def run(self):
        """Start the fpga build run."""
        success = False
        click.secho('Starting ZyCAP build flow...', fg='magenta')
        click.secho('Project Name: {}'.format(self.design_name), fg='blue')
        click.secho('Tool Version: {}'.format(self.xilinx_version), fg='blue')
        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')
        _,success = self.source_tools('{0}/{1}/settings64.sh'.format(self.vivado_path,self.xilinx_version))
        self.verify('Setup',success)
        self.extract()
        self.generate()

    def extract(self):
        """Extract PR modules. Walks the current working directory for module files."""
        click.secho('Discovering User Configurations...', fg='magenta')
        self.configs = self.config['design']['design_configurations']
        modules = set()
        for config in self.config['design']['design_configurations'].keys():
            self.logger.info(f"Found config: {config}")
            modes = {}
            for mode in self.config['design']['design_configurations'][config]['modes'].keys():
                self.logger.info(f" ∟ Found mode: {mode}")
                modes[mode] = self.config['design']['design_configurations'][config]['modes'][mode]
                for module in modes[mode]['modules']:
                    if module not in modules:
                        modules.add(module)
                    self.logger.info(f"   ∟ Found module: {module}")
            self.configs[config] = modes
        success,check_modules = self.check_files_exist(self.root_path, modules, '.v')
        if not success:
            self.logger.error(f'Cannot find modules {check_modules}')
        self.verify('Extract Modules',success)

    def __extract_interfaces(self,module):
        

    def generate(self):
        success = True
        self.verify('Generate Checkpoints',success)


