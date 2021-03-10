#!/bin/bash

import os
import sys
import json
import subprocess
from .utils.tool import Tool
import click
import click_spinner
import time
import pkg_resources
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

class Build(Tool):
    def __init__(self, logger, json=None, force=False):  
        self.logger = logger        
        self.force = force
        success = self.unpack_config(self.load_config(json))
        self.verify('Setup', success)
        _, success = self.source_tools(
            '{0}/{1}/settings64.sh'.format(self.sdk_path, self.xilinx_version))
        self.verify('Setup', success)
        self.__set_tool(self.xilinx_version)

    def unpack_config(self, config):
        try:
            self.device = config['project']['project_device']['family']
            self.board = config['project']['project_device']['board']
            self.board_name = config['project']['project_device']['name']
            self.board_version = config['project']['project_device']['version']
            self.design_name = config['design']['design_name']
            self.project_name = config['project']['project_name']
            self.xilinx_version = config['config']['config_xilinx']['xilinx_version']
            self.proxy = self.exists(
                config['config']['config_xilinx']['xilinx_proxy'])
            self.petalinux_path = config['config']['config_petalinux']['petalinux_path']
            self.sdk_path = config['config']['config_sdk']['sdk_path']
            self.work_root = 'build'
            self.root_path = os.getcwd()
            return True
        except:
            return False

    def run(self):
        click.secho('Starting ZyCAP Linux build...', fg='magenta')
        click.secho('project name: {}'.format(self.design_name), fg='blue')
        click.secho('sdk version: {}'.format(self.xilinx_version), fg='blue')
        self.logger.info('loading config')
        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')
        self.source_tools(f'{self.petalinux_path}/settings.sh',True)
        click.secho('setup complete [✓]',fg='green')

        self.setup()
        self.generate()

    def __set_tool(self, version):
        self.sdk_tool = 'xsct'

    @Tool.verify_func
    def __fsbl(self, bootloader_files):
        click.secho('Generating fsbl...', fg='magenta')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'{self.sdk_tool} {bootloader_files}/fsbl/build.tcl {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE)
            output, success = process.communicate()
        return success

    @Tool.verify_func
    def __pmufw(self, bootloader_files):
        click.secho('Generating pmufw...', fg='magenta')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'{self.sdk_tool} {bootloader_files}/pmufw/build.tcl {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE)
            output, success = process.communicate()
        return success

    @Tool.verify_func
    def __atf(self, bootloader_files):
        click.secho('Generating arm trusted firmware...', fg='magenta')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'bash {bootloader_files}/atf/build.sh {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, success = process.communicate()
            print(output)
        return success

    @Tool.verify_func
    def __uboot(self, bootloader_files):
        click.secho('Generating uboot...', fg='magenta')
        self._create_path(Path.cwd() / self.work_root / f'{self.project_name}.sdk' / 'uboot' / 'src')
        self.copytree(f'{bootloader_files}/uboot/src', f'./{self.work_root}/{self.project_name}.sdk/uboot/src')
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'bash {bootloader_files}/uboot/build.sh {self.project_name} {self.work_root}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, success = process.communicate()
        return success

    @Tool.verify_func
    def __image(self, bootloader_files):
        click.secho('Generating boot image...', fg='magenta')

        jinja_env = Environment(loader=FileSystemLoader(bootloader_files))

        p = Path(f"{self.work_root}/{self.project_name}.bitstreams").glob('*.bit')
        bitstreams = [x.absolute() for x in p if x.is_file()]
        self.logger.info(bitstreams)

        self._renderTemplate(jinja_env, 'boot.bif.j2', Path.cwd() / self.work_root / f'{self.project_name}.sdk' / 'boot.bif', template_vars={'bitstreams' : bitstreams})
        self._create_path(Path.cwd() / self.work_root / f'{self.project_name}.sdk' / 'uboot' / 'src')

        self.logger.info("Building BOOT.BIN...")
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'bootgen -arch zynqmp -image {self.work_root}/{self.project_name}.sdk/boot.bif -w -o {self.work_root}/{self.project_name}.sdk/boot.bin'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE
                )
            output, success = process.communicate()
        return success

    @Tool.verify_func
    def __device_tree(self, vitis_scripts):
        self._create_path(Path.cwd() / self.work_root / f'{self.project_name}.sdk' / 'device_tree')
        
        with click_spinner.spinner():
            process = subprocess.Popen(
                f'bash {vitis_scripts}/dt/dtg.sh {self.work_root}/{self.project_name}.sdk/device_tree {self.xilinx_version}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output, success = process.communicate()

            if success == False:
                return success

            print(f'{self.sdk_tool} {vitis_scripts}/dt/dtg.tcl {self.project_name} {self.work_root} psu_cortexa53_0 {self.work_root}/{self.project_name}.sdk/device_tree/dtg')
            exit()
            process = subprocess.Popen(
                f'{self.sdk_tool} {vitis_scripts}/dt/dtg.tcl {self.project_name} {self.work_root} psu_cortexa53_0 {self.work_root}/{self.project_name}.sdk/device_tree/dtg'.split(), stdout=subprocess.PIPE)
            output, success = process.communicate()
            print(output)
            return success


    def setup(self):
        self.kernel_path = Path.cwd() / self.work_root / f'{self.project_name}.linux' / 'kernel'
        self._create_path(self.kernel_path)

    def generate(self):
        board = self.board.replace(':','/')

        bootloader_files = pkg_resources.resource_filename(
            'zycap', f'boards/{board}/linux/{self.xilinx_version}')
        self.logger.info(bootloader_files)

        vitis_scripts = pkg_resources.resource_filename(
            'zycap', f'scripts/vitis')
        self.logger.info(vitis_scripts)
        success = True

        self.__device_tree(vitis_scripts)
        exit()

        if all([self.__fsbl(bootloader_files), self.__pmufw(bootloader_files), self.__atf(bootloader_files), self.__uboot(bootloader_files), self.__image(bootloader_files),self.__device_tree(vitis_scripts)]):
            self.logger.info("Generation all boot components successful!")
        else:
            exit(1)


        # self.__device_tree(vitis_scripts)

        exit()

        self.__prepare_kernel()

        self.export()
        pass

    @Tool.verify_func
    def __prepare_petalinux(self, linux_docker, tool, version):
        success = True
        self.logger.info(f'Starting HTTP server')
        process = subprocess.Popen(
            f'bash {linux_docker}/serve-petalinux.sh {linux_docker} {version}'.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        process.wait()
        self.logger.info(f'Starting build')
        self.docker_build_image(linux_docker,f'zycap/{tool}/{self.xilinx_version}')
        self.logger.info(f'Using {linux_docker}/Dockerfile to build Linux Kernel')
        
        try:
            container = self.docker.containers.get(f'{tool}-{version}-kernel')
            container.stop()

        except: 
            self.logger.warning(f'{tool}-{version}-kernel not running...')
            container = self.docker.containers.run(
                                                    image=f'zycap/{tool}/{self.xilinx_version}',
                                                    stdin_open = True,
                                                    tty = True,
                                                    name=f'{tool}-{version}-kernel',
                                                    volumes={self.kernel_path: {'bind': '/home/plnx/project', 'mode': 'rw'}},
                                                    detach=True
                                                )            
        container.start()
        if container.status == "running":
            if (container.exec_run("/bin/bash -c 'for i in $(ls -d */); do echo ${i%%/}; done'",user='plnx').output.decode().strip() != self.project_name) and not self.force:
                self.logger.warning(f"Project {self.project_name} not found, creating...")
                build = container.exec_run(f"/bin/bash -c 'source /opt/petalinux/settings.sh && petalinux-create --type project --template zynqMP --name {self.project_name}'",user='plnx')
                if build.exit_code != 0:
                    self.logger.warning(build.output.decode())
                    return False
            # Copy in base Petalinux Project
            board = self.board.replace(':','/')
            project_spec = pkg_resources.resource_filename(
                'zycap', f'boards/{board}/linux/{self.xilinx_version}/petalinux/project-spec')
            self.logger.info(f'Found {project_spec}')
            self.copytree(project_spec, f"{self.work_root}/{self.project_name}.linux/kernel/{self.project_name}/project-spec")
            self.logger.info(f"Starting Kernel build")
            self.__build_petalinux(container)

        else:
            self.logger.warning(f'Docker error - {container.status}')
            success = False
        return success

    def __build_petalinux(self, container):
        petalinux = container.exec_run(f"/bin/bash -c 'source /opt/petalinux/settings.sh && cd {self.project_name} && petalinux-build'",user='plnx',socket=True)
        print(petalinux.exit_code)
        while petalinux.exit_code == None:
            print("building...")
            time.sleep(5) 
        # while petalinux.output.fileno() != -1:
        #     data = petalinux.output.read(1024)
        #     print(data.decode('utf_8', 'ignore'))
    
    @Tool.verify_func
    def __prepare_kernel(self, tool="petalinux", version="2019.2"):
        success = True
        linux_docker = pkg_resources.resource_filename(
            'zycap', f'docker/{tool}/{self.xilinx_version}')
        self.docker_config()
        with click_spinner.spinner():
            self.logger.info(f'Using {linux_docker}/Dockerfile to build Linux Kernel')
            try: 
                self.logger.info(f"Found {self.docker.images.get(f'zycap/{tool}/{self.xilinx_version}').tags}...")
            except:
                self.logger.warning(f'Docker image for zycap/{tool}/{self.xilinx_version} not found...')
            if tool == "petalinux":
                self.__prepare_petalinux(linux_docker, tool, version)
                    

            # print(container.top())
        return success

    def export(self):
        pass