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

from edalize import *


class Build(Tool):
    def __init__(self, logger, json=None, force=False):
        self.logger = logger
        self.force = force
        self.config = self.load_config(json)
        self.config['filename'] = json
        self.root_path = Path.cwd()
        self.project_name = self.config['project']['project_name']
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
        self.tcl_scripts = []
        self.rtl_hash = self.hash_directory(self.rtl_directory)
        self.work_root = 'build'

    def setup_vivado_project(self):
        board = self.board.replace(':','/')

        self.logger.info(f"Generating Vivado Project for {board}...")

        bd_files = pkg_resources.resource_filename(
            'zycap', f'scripts/vivado/generate_bd_wrapper.tcl')
        self.logger.info(bd_files)

        gen_bd_files = pkg_resources.resource_filename(
            'zycap', f'scripts/vivado/generate_hwdef.tcl')
        self.logger.info(bd_files)

        board_files = pkg_resources.resource_filename(
            'zycap', f'boards/{board}/bd/{self.xilinx_version}')
        self.logger.info(board_files)
        success = True

        self.logger.debug(f"Board files: {board_files}...")

        build_path = Path.cwd() / self.work_root / '.inst'
        self._create_path(build_path)

        inst_path = Path.cwd() / self.work_root / f'{self.project_name}.inst'
        self._create_path(inst_path)

        checkpoint_path = Path.cwd() / self.work_root / '.checkpoint'
        self._create_path(checkpoint_path)

        sdk_path = Path.cwd() / self.work_root / f'{self.project_name}.sdk'
        self._create_path(sdk_path)

        board_constraint = Path(f'{board_files}/src/constraint.xdc')
        board_bd = Path(f'{board_files}/base.tcl')

        defines = {'design_name':self.project_name,'test':1000}

        with open(f"{self.work_root}/{self.project_name}_params.tcl", "w+") as file:
            for each in defines:
                print(each,defines[each])
                file.write(f"set {each} {defines[each]}\n")

        files = [
        {'name':f"{self.project_name}_params.tcl",'file_type': 'tclSource'},
        {'name' : board_bd.as_posix(),'file_type' : 'tclSource'},
        {'name' : board_constraint.as_posix(),'file_type' : 'xdc'},
        {'name' : bd_files, 'file_type':'tclSource'},
        # {'name' : os.path.relpath('build-ps.tcl', work_root),
        # 'file_type' : 'tclSource'},
        # {'name' : os.path.relpath('blinky.v', work_root),
        # 'file_type' : 'verilogSource'},
        # {'name' : os.path.relpath('constraint.xdc', work_root),
        # 'file_type' : 'xdc'},
        ]

        parameters = {
            'clk_freq_hz' : {'datatype' : 'int', 'default' : 1000, 'paramtype' : 'vlogparam'},
            'design_name': {'datatype' : 'str', 'default' : 2000, 'paramtype' : 'cmdlinearg'}
        }

        tool_options = {
            'part': self.part,
            'vivado-settings': f'{self.vivado_path}/{self.xilinx_version}/settings64.sh'
        }   

        generate_sdk_files = {
            'name': 'generate_sdk_files',
            'cmd' : [f"{self.tool_path}/Vivado/{self.xilinx_version}/bin/vivado", "-mode", "batch", "-source", gen_bd_files, "-tclargs", self.project_name]
        }

        move_bitstreams = {
            'name': 'move_bitstreams',
            'cmd' : ["cp", "*.bit", f"{self.project_name}.bitstreams"]
        }

        hooks = {
            'post_build' : [generate_sdk_files, move_bitstreams]
        }



        self.edam = {
        'files'        : files,
        'name'         : self.project_name,
        'parameters'   : parameters,
        'toplevel'     : f'{self.project_name}_wrapper',
        'tool_options': {'vivado' : tool_options},
        'hooks' : hooks
        }

        # self.edam['files'][:0] = [{'name' : board_constraint.as_posix(),
        # 'file_type' : 'verilogSource'}]

        self.backend = get_edatool('vivado')(edam=self.edam,
                                    work_root=self.work_root)
        
        # backend.configure()
        # # args = {'test' : 1000}

        # backend.run()
        # exit()


    def generate_configs(self):
        pass

    def run(self):
        """Start the fpga build run."""
        success = False
        click.secho('Starting ZyCAP FPGA build...', fg='magenta')
        click.secho('Project Name: {}'.format(self.design_name), fg='blue')
        click.secho('Tool Version: {}'.format(self.xilinx_version), fg='blue')
        click.secho('Target Device: {}'.format(self.part), fg='blue')
        click.secho('Board: {}'.format(self.board), fg='blue')  
        click.secho('Project Version: {}'.format(self.rtl_hash), fg='blue')
        self.logger.info("Starting toolflow...")

        if self.proxy is not None:
            click.secho('proxy: {}'.format(self.proxy), fg='blue')
        _, success = self.source_tools(
            '{0}/{1}/settings64.sh'.format(self.vivado_path, self.xilinx_version))
        self.verify('Setup', success)
        with open(f"{self.work_root}/.hash", "r") as f:
            hash_file = f.readline()

        if hash_file != self.rtl_hash:
            self.logger.warning('detected file changes in RTL')
            self.changes = True
        else:
            self.changes = False

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
        click.secho('Extracting Interfaces...', fg='magenta')
        for module in self.modules['modules']:
            inter = Interface()
            interfaces, protocols = self.__ext_interfaces(module, inter)
            # self.logger.error(f'ERROR: {inter.protocol_dict}')
            try:
                self.protocol_dict = inter.protocol_dict.keys() & self.protocol_dict.keys()
            except:
                self.protocol_dict = inter.protocol_dict

        # self.logger.info(interfaces)
        # self.logger.info(protocols)
        self.interfaces = interfaces
        self.protocols = protocols
        self.logger.debug(self.pprint(self.protocol_dict))
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
        with open(f"{self.work_root}/.hash", "w") as f:
            f.write(self.hash_directory(self.rtl_directory))
        self.setup_vivado_project()
        if all([self.__gen_modules(), self.__gen_infrastructure(), self.__gen_wrapper(), self.__gen_base(self.board)]):
            self.logger.info("Generation all successful!")
            self.export()
        else:
            exit(1)
        

    def __gen_modules(self):
        click.secho('Generating PR Module Checkpoints...', fg='magenta')
        prr = 2
        mods = self.modules['modules']
        # print(mods['fir']['obj'].ports)
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
            gen.render(f"{self.work_root}/example.inst/", prr=pr)

        # Check for differences in checkpoint files before regenerating checkpoints
        p = Path(f'{self.work_root}/.checkpoint')  
        checkpoints = [y for y in p.rglob(f'*.dcp')] 

        if self.changes == True or (len(checkpoints) != len(mod_list)):
            self.logger.info("Changes identifies in PR module checkpoints...")
            self.edam['files'].insert(1, {'name' : '.inst/gen_modules.tcl',
            'file_type' : 'tclSource'})

        success = True

        # with click_spinner.spinner():
        #     log, success = self.xilinx_tool(self.tool_path,
        #                                     "Vivado",
        #                                     self.xilinx_version,
        #                                     f"{self.work_root}/.inst/gen_modules.tcl -tclargs True")

        self.backend.configure()

        return self.verify('Generate Module Checkpoints', success)

    def __gen_base(self, device, custom=None):
        click.secho(
            f'Generating Base Design for {self.board_name}...', fg='magenta')

        self.backend.configure()

        with open(f'{self.work_root}/{self.project_name}.tcl', 'a') as f:
            f.write('set_property source_mgmt_mode All [current_project]')

        try:
            self.backend.build()
            success = True
        except:
            self.logger.error("Problems with Vivado build process")
            success = False
        return self.verify('Generated Base Design', success)

    def __gen_wrapper(self):
        self.edam['files'].insert(1, {'name' : str(Path(f"{self.work_root}/{self.project_name}.inst/wrapper.v").absolute().relative_to(Path.cwd() / self.work_root)),
                'file_type' : 'verilogSource'})



    def __gen_infrastructure(self):
        self.logger.info("Generating Infrastructure...")

        ip_path = Path.cwd() / self.work_root / f'{self.project_name}.ip'
        self._create_path(ip_path)

        ip_config = pkg_resources.resource_filename(
            'zycap', 'ip') + '/'
        self.logger.info(ip_config)
        success = True

        # Check that interface module exists
        self.logger.debug(f'Checking that ip exists for {self.xilinx_version}')
        for ip_core in Path(ip_config).iterdir():
            if not Path(f'{ip_core}/' + self.xilinx_version).is_dir():
                self.logger.warning(
                    f"{ip_core} does not exist for version {self.xilinx_version}")
                success = False
                return self.verify('Generated Infrastructure', False)

        # Loop through discovered protocols and apply infrastructure based upon them        
        for interface in self.protocol_dict:
            for protocol in self.protocol_dict[interface].keys():
                try:
                    interface_script = f"{ip_config}{interface.lower()}/{self.xilinx_version}/{protocol.lower()}.py"
                    if Path(f"{ip_config}{interface.lower()}/src").is_dir():
                        for each in Path(f"{ip_config}{interface.lower()}/src").glob(f'{protocol.lower()}*'):
                            self.edam['files'].insert(1, {'name' : str(each), 'file_type' : 'verilogSource'})
                    interface_len = len(self.protocol_dict[interface][protocol])
                    self.logger.debug(self.protocol_dict[interface][protocol])
                    self.logger.info(f'Found {interface_len} interfaces for {interface} - {protocol}')
                    output = open(f'{self.root_path}/.logs/{interface}-{protocol}.log', 'w+')
                    e = subprocess.run(
                        f'{interface_script} -p {interface_len} -o {self.work_root}/{self.project_name}.ip/{interface}_{protocol}.v'.split(), stdout=output, stderr=output)
                    if e.returncode != 0:
                        self.logger.error(f"Error {e} in IP generation")
                        return self.verify('Generated Infrastructure', False)
                except Exception as e:
                    self.logger.warning(f'No IP for {interface} - {protocol}')

        # Generate ICAP infrastructure
        try:
            interface_script = f"{ip_config}icap/{self.xilinx_version}/icape.py"
            if self.family == "zynq-ultrascale":
                version = 3
            else:
                version = 2
            self.logger.debug(f"Attempting to generate ICAP interface for {self.family} - ICAPE{version}")
            output = open(f'{self.root_path}/.logs/icap.log', 'w+')
            e = subprocess.run(
                f'{interface_script} -n icap -v {version} -o {self.work_root}/{self.project_name}.ip/ICAP.v'.split(), stdout=output, stderr=output)
            if e.returncode != 0:
                self.logger.error(f"Error {e} in ICAP generation")
                return self.verify('Generated Infrastructure', False)
        except Exception as e:
            self.logger.error(f'Error generating ICAP - {e}')
            success = False

        ip_script = pkg_resources.resource_filename(
            'zycap', f'scripts/vivado/generate_bd_wrapper.tcl')
        
        # self.edam['files'].insert(1, {'name' : str(each.relative_to(Path.cwd() / self.work_root)),
        #     'file_type' : 'verilogSource'})

        for each in ip_path.glob('*.v'):
            print(each)
            self.logger.info(f"Appending IP file {str(each.relative_to(Path.cwd() / self.work_root))} to project")
            self.edam['files'].insert(1, {'name' : str(each.relative_to(Path.cwd() / self.work_root)),
                'file_type' : 'verilogSource'})

        return self.verify('Generated Infrastructure', success)

    def export(self):
        pass