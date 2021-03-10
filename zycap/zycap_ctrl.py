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

class ZycapCtrl(Tool):
    def __init__(self, logger, config=None, force=False):  
        self.logger = logger        
        self.force = force
        # success = self.unpack_config(config)
        success = True
        self.verify('Setup', success)

    def unpack_config(self, config):
        try:
            self.axis = config['axis']
            self.gpio = config['gpio']
            self.project_name = config['project_name']
            self.work_root = config['work_root']
            self.root_path = os.getcwd()
            self.zycap_version = config['version']
            return True
        except:
            return False

    def build(self, output_path):
        from shutil import copyfile
        copyfile("/home/alex/GitHub/zycap2/zycap/test/demo/rtl/zycap.v","/home/alex/GitHub/zycap2/zycap/test/demo/build/example.inst/zycap.v")
    