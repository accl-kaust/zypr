import click
import os
import subprocess
import pkg_resources
import shutil
import logging
from pathlib import Path
import glob
import json
import hashlib
from _hashlib import HASH as Hash
from typing import Union
from distutils.dir_util import copy_tree
import docker
import re

class Tool(object):
    def exists(self, x): 
        return None if x == '' else x

    def pprint(self,text):
        return json.dumps(text, indent=4, sort_keys=True)

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

    def verify_func(func):
        def test(*args, **kwargs):
            success = func(*args, **kwargs)
            if not success:
                click.secho('{} failed [✗]'.format(func.__name__), fg='red')
            else:
                click.secho('{} complete [✓]'.format(func.__name__), fg='green')
            return success
        return test

    def hash_directory(self, path):
        digest = hashlib.sha1()

        for root, dirs, files in os.walk(path):
            for names in files:
                file_path = os.path.join(root, names)

                # Hash the path and add to the digest to account for empty files/directories
                digest.update(hashlib.sha1(file_path[len(path):].encode()).digest())

                # Per @pt12lol - if the goal is uniqueness over repeatability, this is an alternative method using 'hash'
                # digest.update(str(hash(file_path[len(path):])).encode())

                if os.path.isfile(file_path):
                    with open(file_path, 'rb') as f_obj:
                        while True:
                            buf = f_obj.read(1024 * 1024)
                            if not buf:
                                break
                            digest.update(buf)

        return digest.hexdigest()

    def source_tool(self, xilinx_dir, tool, version) -> (str, bool):
        output = open(f'.logs/{tool}.log', 'w+')
        os.system(f'bash {xilinx_dir}/{tool.title()}/{version}/settings64.sh')
        # e = subprocess.run(
        #     f'bash source {xilinx_dir}/{tool.title()}/{version}/settings64.sh'.split(), stdout=output, stderr=output)
        if e.returncode != 0:
            return (f'.logs/{tool}.log', False)
        else:
            return (f'.logs/{tool}.log', True)

    def xilinx_tool(self, xilinx_dir, tool, version, tcl) -> (str, bool):
        output = open(f'.logs/{tool}_{Path(tcl).stem}.log', 'w+')
        e = subprocess.run(
            f'{xilinx_dir}/{tool.title()}/{version}/bin/{tool.lower()} -mode batch -nojournal -nolog -notrace -source {tcl}'.split(), stdout=output, stderr=output)
        if e.returncode != 0:
            return (f'.logs/{tool}_{tcl}.log', False)
        else:
            return (f'.logs/{tool}_{tcl}.log', True)

    def docker_config(self):
        self.docker = docker.from_env()
        return 

    def docker_build_image(self, dockerfile, tag):
        self.docker.images.build(path=dockerfile, quiet=False, tag=f'{tag}')
        pass

    def docker_run(self, image):

        pass

    def check_files_exist(self, root, files: set, ext: str) -> (bool, list):
        temp_files = files
        path_files = {}
        self.logger.info('Searching for: {} in {} of type ({})'.format(files, root, ext))
        for each in glob.glob(f'{root}/**/*{ext}', recursive=True):
            # stem = Path(each).stem
            if Path(root).stem != str(Path(each).parent.stem):
                stem = str(Path(each).parent.stem)+"/"+Path(each).stem
            else:
                stem = Path(each).stem
                print(f'{Path(root).stem} - {str(Path(each).parent.stem)}')


            if stem in temp_files:
                self.logger.info('Found {}'.format(stem))
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

    def _renderTemplate(self, jinja_env, template_file, target_file, template_vars={}):
        template = jinja_env.get_template(template_file)
        with open(target_file, 'w') as f:
            f.write(template.render(template_vars))

    def _create_path(self,path,force=False):
        try:
            if(force and path.is_dir()):
                self.logger.debug(f"Directory '{path.as_posix()}' already exists, overwriting...")
                shutil.rmtree(path)
            path.mkdir(parents=True, exist_ok=force)

        except FileExistsError:
            self.logger.debug(f"Directory '{path.as_posix()}' already exists")
        else:
            self.logger.debug(f"Directory '{path.as_posix()}' created")

    def copytree(self, src, dst):
        copy_tree(src, dst)

    def source_tools(self, command, quiet=False) -> (bool, bool):
        self.logger.debug(f'Running {command}')
        if quiet:
            process = subprocess.Popen(". %s; env -0" % command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, 
                                    shell=True, executable='/bin/bash', universal_newlines=True)
            output, error = process.communicate()
        else:
            process = subprocess.Popen(". %s; env -0" % command, stdout=subprocess.PIPE,
                                    shell=True, executable='/bin/bash', universal_newlines=True)
            output, error = process.communicate()
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
