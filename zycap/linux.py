#!/bin/bash

import os
import sys
import json
import subprocess
from .utils.tool import Tool
import click
import pkg_resources

class Build(Tool):
    def __init__(self, logger, json=None):  
        self.logger = logger        
        self.config = self.load_config(json)
        self.root_path = os.getcwd()
        self.device = self.config['project']['project_device']['family']
        self.board_name = self.config['project']['project_device']['name']
        self.board_version = self.config['project']['project_device']['version']
        self.design_name = self.config['design']['design_name']
        self.xilinx_version = self.config['config']['config_xilinx']['xilinx_version']
        self.proxy = Tool.exists(self.config['config']['config_vivado']['vivado_proxy'])
        self.petalinux_path = self.config['config']['config_petalinux']['petalinux_path']

    def run(self):
        click.secho('starting ZyCAP build flow...', fg='magenta')
        click.secho('project name: {}'.format(self.design_name), fg='blue')
        click.secho('vivado version: {}'.format(self.xilinx_version), fg='blue')
        self.logger.info('loading config')
        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')
        self.source_tools('{}/{}/settings.sh'.format(self.petalinux_path,self.xilinx_version))
        click.secho('setup complete [✓]',fg='green')