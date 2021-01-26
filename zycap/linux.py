#!/bin/bash

import os
import sys
import json
import subprocess
from .utils.tool import Tool
import click
import click_spinner
import pkg_resources
from pathlib import Path

class Build(Tool):
    def __init__(self, logger, json=None):  
        self.logger = logger        
        self.config = self.load_config(json)
        self.root_path = os.getcwd()
        self.device = self.config['project']['project_device']['family']
        self.board = self.config['project']['project_device']['board']
        self.board_name = self.config['project']['project_device']['name']
        self.board_version = self.config['project']['project_device']['version']
        self.design_name = self.config['design']['design_name']
        self.project_name = self.config['project']['project_name']
        self.xilinx_version = self.config['config']['config_xilinx']['xilinx_version']
        self.proxy = self.exists(
            self.config['config']['config_xilinx']['xilinx_proxy'])
        self.petalinux_path = self.config['config']['config_petalinux']['petalinux_path']
        self.sdk_path = self.config['config']['config_sdk']['sdk_path']
        self.work_root = 'build'
        _, success = self.source_tools(
            '{0}/{1}/settings64.sh'.format(self.sdk_path, self.xilinx_version))
        self.verify('Setup', success)
        self.__set_tool(self.xilinx_version)

    def run(self):
        click.secho('Starting ZyCAP Linux build...', fg='magenta')
        click.secho('project name: {}'.format(self.design_name), fg='blue')
        click.secho('sdk version: {}'.format(self.xilinx_version), fg='blue')
        self.logger.info('loading config')
        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')
        self.source_tools(f'{self.petalinux_path}/settings.sh',True)
        click.secho('setup complete [✓]',fg='green')

        self.generate()

    def __set_tool(self, version):
        self.sdk_tool = 'xsct'

    def __fsbl(self, bootloader_files):
        click.secho('Generating fsbl...', fg='magenta')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'{self.sdk_tool} {bootloader_files}/fsbl/build.tcl {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE)
            output, success = process.communicate()
        return success

    def __pmufw(self, bootloader_files):
        click.secho('Generating pmufw...', fg='magenta')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'{self.sdk_tool} {bootloader_files}/pmufw/build.tcl {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE)
            output, success = process.communicate()
        return success

    def __atf(self, bootloader_files):
        click.secho('Generating arm trusted firmware...', fg='magenta')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'bash {bootloader_files}/atf/build.sh {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, success = process.communicate()
            print(output)
        return success

    def __uboot(self, bootloader_files):
        click.secho('Generating uboot...', fg='magenta')
        self._create_path(Path.cwd() / self.work_root / f'{self.project_name}.sdk' / 'uboot' / 'src')
        self.copytree(f'{bootloader_files}/uboot/src', f'./{self.work_root}/{self.project_name}.sdk/uboot/src')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'bash {bootloader_files}/uboot/build.sh {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, success = process.communicate()
        return success

    def generate(self):
        board = self.board.replace(':','/')

        bootloader_files = pkg_resources.resource_filename(
            'zycap', f'boards/{board}/linux/{self.xilinx_version}')
        self.logger.info(bootloader_files)
        success = True

        if all([self.__fsbl(bootloader_files), self.__pmufw(bootloader_files), self.__atf(bootloader_files), self.__uboot(bootloader_files)]):
            self.logger.info("Generation all successful!")
            self.export()
        else:
            exit(1)
        pass

    def export(self):
        pass