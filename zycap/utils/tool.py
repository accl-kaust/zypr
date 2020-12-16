import click
import os
import subprocess
import pkg_resources
import logging
from pathlib import Path
import glob
import json


class Tool(object):
    def exists(self, x): return None if x == '' else x

    def __init__(self, deps=None):
        self.check_dependencies = deps
        pass

    def verify(self, process, success=False):
        if not success:
            click.secho('{} failed [✗]'.format(process), fg='red')
            exit()
        else:
            click.secho('{} complete [✓]'.format(process), fg='green')
            return success

    def xilinx_tool(self, xilinx_dir, tool, version, tcl) -> (str, bool):
        output = open(f'.logs/{tool}_{Path(tcl).stem}.log', 'w+')
        e = subprocess.run(
            f'{xilinx_dir}/{tool.title()}/{version}/bin/{tool.lower()} -mode batch -nojournal -nolog -notrace -source {tcl}'.split(), stdout=output, stderr=output)
        if e.returncode != 0:
            return (f'.logs/{tool}_{tcl}.log', False)
        else:
            return (f'.logs/{tool}_{tcl}.log', True)

    def check_files_exist(self, root, files: set, ext: str) -> (bool, list):
        temp_files = files
        path_files = {}
        self.logger.info('Searching for: {}'.format(files))
        for each in glob.glob(f'{root}/**/*{ext}', recursive=True):
            stem = Path(each).stem
            if stem in temp_files:
                temp_files.discard(stem)
                path_files[stem] = Path(each)
        result = files.intersection(temp_files)
        self.logger.info('{}'.format(not bool(result)))
        return (not bool(result), path_files)

    def load_config(self, filename):
        try:
            if filename is None:
                filename = pkg_resources.resource_filename(
                    'zycap', 'config/global.json')
            self.logger.info('{}'.format(filename))
            with open(filename) as j:
                return json.load(j)
        except Exception as e:
            click.secho('error: {}'.format(e), fg='red')
            exit()

    def source_tools(self, command) -> (bool, bool):
        # process = subprocess.Popen(command.split(), stdout=subprocess.PIPE,shell=True, executable='/bin/bash')
        process = subprocess.Popen(". %s; env -0" % command, stdout=subprocess.PIPE,
                                   shell=True, executable='/bin/bash', universal_newlines=True)
        output, error = process.communicate()
        # env = dict((line.split("=", 1) for line in output.split('\x00')))
        os.environ.update(line.partition('=')[::2]
                          for line in output.split('\0'))
        if error is not None:
            click.secho('error [✗]: {}'.format(error), fg='red')
            error = False
        else:
            error = True
        return (output, error)

    def loading(self, process):
        pass

    def clean_directory(self, path):
        if os.path.isfile("rtl/{}".format(path)):
            click.secho(
                'error: design name - {} - conflicts with rtl files'.format(path), fg='red')
            exit()
        s = subprocess.Popen(
            'rm -rf rtl/.* rtl/{} rtl/hd_visual'.format(path).split(), stdout=subprocess.PIPE)
        self.loading(s)
