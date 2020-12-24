import os
import sys
import json
import glob
import subprocess
from .utils.tool import Tool
import click
import click_spinner
from pathlib import Path
import shutil
import pkg_resources
from interfacer.generate import Generate
from interfacer.identify import Identify
from interfacer.module import Module, Static
from interfacer.interface import Interface


class Build(Tool):
    def __init__(self, logger, json=None, linux=True, force=False):
        self.logger = logger
        self.force = force
        self.config = self.load_config(json)
        self.config['filename'] = json
        self.root_path = Path.cwd()
        self.rtl_directory = self.config['design']['design_directory']
        self.family = self.config['project']['project_device']['family']
        self.part = self.config['project']['project_device']['device'] + \
            self.config['project']['project_device']['package'] + \
            self.config['project']['project_device']['speed'] + \
            self.config['project']['project_device']['option']
        self.board = self.config['project']['project_device']['board']
        self.board_name = self.config['project']['project_device']['name']
        self.board_version = self.config['project']['project_device']['version']
        self.design_name = self.config['design']['design_name']
        self.tool_path = self.config['config']['config_tools']['tools_path']
        self.vivado_path = self.config['config']['config_vivado']['vivado_path']
        self.xilinx_version = self.config['config']['config_xilinx']['xilinx_version']
        self.vivado_params = self.config['config']['config_vivado']['vivado_params']
        self.proxy = self.exists(
            self.config['config']['config_xilinx']['xilinx_proxy'])
        self.petalinux_path = self.config['config']['config_petalinux']['petalinux_path']

    def generate_configs(self):
        pass

    def run(self):
        """Start the fpga build run."""
        success = False
        click.secho('Starting ZyCAP build flow...', fg='magenta')
        click.secho('Project Name: {}'.format(self.design_name), fg='blue')
        click.secho('Tool Version: {}'.format(self.xilinx_version), fg='blue')
        click.secho('Target Device: {}'.format(self.part), fg='blue')
        self.logger.info("Starting toolflow...")

        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')
        _, success = self.source_tools(
            '{0}/{1}/settings64.sh'.format(self.vivado_path, self.xilinx_version))
        self.verify('Setup', success)
        self.extract()
        self.generate()

    def extract(self):
        """Extract PR modules. Walks the current working directory for module files."""
        click.secho('Discovering Modes & Configurations...', fg='magenta')
        mode_store = self.config['design']['design_mode']
        config_store = {}
        self.modules = {}
        self.modules['modules'] = {}

        iden = Identify()

        ip_files = set()
        configs = set()
        modes = set()
        for mode in mode_store.keys():
            self.logger.info(f"Mode: {mode}")
            modes.add(mode)
            for config in mode_store[mode]['configs'].keys():
                self.logger.info(f" ∟ Config: {config}")
                configs.add(config)
                config_store[mode] = mode_store[mode]['configs'][config]
                for module in mode_store[mode]['configs'][config]['modules']:
                    self.modules['modules'][module] = {}
                    module_files = set()
                    for rtl in mode_store[mode]['configs'][config]['modules'][module]['rtl']:
                        module_files.add(Path(rtl).stem)
                    if 'ip' in mode_store[mode]['configs'][config]['modules'][module]:
                        for ip in mode_store[mode]['configs'][config]['modules'][module]['ip']:
                            ip_files.add(Path(ip).stem)
                        self.modules['modules'][module]['ipcores'] = mode_store[mode]['configs'][config]['modules'][module]['ip']
                    self.modules['modules'][module]['rtl'] = list(module_files)
                    self.modules['modules'][module]['top_module'] = mode_store[mode]['configs'][config]['modules'][module]['top_module']
                    self.modules['modules'][module]['top_cell'] = mode_store[mode]['configs'][config]['modules'][module]['top_cell']
                    self.logger.info(f"   ∟ Module: {module}")
            config_store[config] = mode_store
        self.configs = configs
        self.modes = modes
        if 'design_static' in self.config['design']:
            static_files = set()
            for each in self.config['design']['design_static']['rtl']:
                static_files.add(Path(each).stem)
            static_files_list = [s + ".v" for s in static_files]
            success, files = self.check_files_exist(
                self.root_path, static_files, '.v')
            if success:
                # TODO: handle ip cores in static design
                self.static = Static(
                    top=self.config['design']['design_static']['top'],
                    directory=self.rtl_directory,
                    files=static_files_list,
                    ipcores=None,
                    xdc=self.config['design']['design_static']['xdc'],
                    version=self.xilinx_version,
                    base=False
                )
        else:
            pass
            # TODO: handle no custom static design

        success, self.modules['files'] = self.check_files_exist(
            self.root_path, module_files, '.v')
        if len(self.modules['files']) > 0:
            self.logger.info(
                f'Found module files {[s + ".v" for s in self.modules["files"]]}')
        if not success:
            self.logger.error(
                f'Missing module files {[s + ".v" for s in module_files]}')

        if len(ip_files) > 0:
            success, self.modules['ipcores'] = self.check_files_exist(
                self.root_path, ip_files, '.xci')
            if not success:
                self.logger.error(
                    f'Missing module ip {[s + ".xci" for s in ip_files]}')
            else:
                self.logger.info(
                    f'Found module ip {[s + ".xci" for s in self.modules["ipcores"]]}')

        # print(self.modules)
        for module in self.modules['modules']:
            self.__ext_modules(module, iden)
        click.secho('Generating Interfaces...', fg='magenta')
        for module in self.modules['modules']:
            inter = Interface()
            interfaces, protocols = self.__ext_interfaces(module, inter)
            # print(inter.matched_interfaces)
        self.logger.info(interfaces)
        self.logger.info(protocols)
        self.interfaces = interfaces
        self.protocols = protocols
        self.verify('Discovering Modules', success)

    def __ext_modules(self, module, iden):
        self.logger.info(f'Preparing module {module}')
        ip = set()
        if 'ipcores' in self.modules['modules'][module]:
            for each in self.modules['modules'][module]['ipcores']:
                ip.add(str(self.modules['ipcores'][Path(each).stem]).split(
                    f'{self.rtl_directory}/')[1])
            # self.modules['modules'][module]['ipcores']

        # TODO: allow for different ipcore paths
        # print(self.modules['modules'][module])
        # print([s + ".v" for s in self.modules['modules'][module]['rtl']])
        self.modules['modules'][module]['obj'] = Module(
            top=self.modules['modules'][module]['top_cell'],
            directory=self.rtl_directory,
            files=[s + ".v" for s in self.modules['modules'][module]['rtl']],
            ipcores=ip,
            version=self.xilinx_version,
            force=False
        )
        # print(f"MODULE FILES {self.modules['modules'][module]['rtl']}")
        print(f"OBJ FILES {self.modules['modules'][module]['obj'].files}")
        json = iden.load(self.modules['modules'][module]['obj'])
        self.modules['modules'][module]['obj'].update(json)

    def __ext_interfaces(self, module, inter):
        interfaces = []
        protocols = []
        print(f"MOD PORTS: {self.modules['modules'][module]['obj'].ports}")
        ports = self.modules['modules'][module]['obj'].ports
        inter.verifyInterface(ports)
        print(self.modules['modules'][module]['obj'].ports)
        for interface in inter.matched_interfaces:
            if interface not in interfaces:
                print(interface)
                # for port in self.modules['modules'][module]['obj'].ports:
                    

                interfaces.append(interface)
        for protocol in inter.protocol_match:
            protocols.append(protocol)

        return interfaces, protocols

    def generate(self):
        if all([self.__gen_modules(), self.__gen_base(self.board), self.__gen_infrastructure()]):
            self.logger.info("Generation all successful!")

    def __gen_modules(self):
        click.secho('Generating Module Checkpoints...', fg='magenta')
        prr = 2
        mods = self.modules['modules']
        print(mods['fir']['obj'].ports)
        mod_list = []
        for mod in mods:
            mod_list.append(self.modules['modules'][mod]['obj'])
        # print(mod_list)
        gen = Generate(static=self.static,
                       modules=mod_list,
                       prr=prr,
                       part=self.part)
        gen.implement()
        for pr in range(prr):
            for mod in mod_list:
                self.logger.info(f'Mod {mod.name}')
                gen.wrapper(mod, xilinx_pragmas=True)
            gen.render("rtl/.inst/", prr=pr)

        with click_spinner.spinner():
            log, success = self.xilinx_tool(self.tool_path,
                                            "Vivado",
                                            self.xilinx_version,
                                            "rtl/.inst/gen_modules.tcl -tclargs True")

        return self.verify('Generate Module Checkpoints', success)

    def __gen_base(self, device, custom=None):
        click.secho(
            f'Generating Base Design for {self.board_name}...', fg='magenta')

        Path(".build").mkdir(parents=True, exist_ok=True)
        project_board = pkg_resources.resource_filename(
            'zycap', 'boards') + '/' + self.board.replace(':', '/')
        shutil.copy(Path(project_board + '/src/constraint.xdc'), ".build")

        with click_spinner.spinner():
            log, success = self.xilinx_tool(self.tool_path,
                                            "Vivado",
                                            self.xilinx_version,
                                            f'{project_board}/bd/base.tcl -tclargs {self.design_name}')

        return self.verify('Generated Base Design', success)

    def __gen_infrastructure_map(self, protocol, direction):
        self.interface_map = {
        'axis': 
            {
                'input':'axis_mux.tcl',
                'output':'axis_demux.tcl'
            }
        }
        pass

    def __gen_infrastructure(self):
        self.logger.info("Generating Infrastructure...")
        ip_config = pkg_resources.resource_filename(
            'zycap', 'ip') + '/'
        success = True

        self.interface_map

        # Check that interface module exists
        for ip_core in Path(ip_config).iterdir():
            if not Path(f'{ip_core}/' + self.xilinx_version).is_dir():
                self.logger.warning(
                    f"{ip_core} does not exist for version {self.xilinx_version}")
                success = False
                break

        # self.__gen_infrastructure_map()




        return self.verify('Generated Infrastructure', success)
