import click
import os
import subprocess
from progress.spinner import Spinner


class tool(object):
    def __init__(self,deps=None):  
        if deps is None:
            self.check_dependencies = self.config['config']['config_settings']['check_dependencies']
        else:
            self.check_dependencies = deps
        pass

    def source_tools(self,command):
        # process = subprocess.Popen(command.split(), stdout=subprocess.PIPE,shell=True, executable='/bin/bash')
        process = subprocess.Popen(". %s; env -0" % command, stdout=subprocess.PIPE, shell=True, executable='/bin/bash', universal_newlines=True)
        output, error = process.communicate()
        # env = dict((line.split("=", 1) for line in output.split('\x00')))
        os.environ.update(line.partition('=')[::2] for line in output.split('\0'))
        if error is not None:
            click.secho('error [✗]: {}'.format(error), fg='red')
            exit()
        return (output,error)

    def loading(self,process):
        spinner = Spinner('Loading ')
        while process.poll() is None:
            spinner.next()

        if deps is None:
            self.check_dependencies = self.config['config']['config_settings']['check_dependencies']
        else:
            self.check_dependencies = deps

    def clean_directory(self,path):
    # Do some work
        if os.path.isfile("rtl/{}".format(path)):
            click.secho('error: design name - {} - conflicts with rtl files'.format(path), fg='red')
            exit()
        s = subprocess.Popen('rm -rf rtl/.* rtl/{} rtl/hd_visual'.format(path).split(), stdout=subprocess.PIPE)
        self.loading(s)

