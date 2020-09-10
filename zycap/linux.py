#!/bin/bash

import os
import sys
import json
import click
import subprocess
import logging
from progress.spinner import Spinner
import pkg_resources

class build(object):
    def __init__(self, json=None,deps=None,clean=None):
        pass

@click.command()
@click.option('--config', default=None, help='Specify configuration file.')
@click.option('--deps', is_flag=True, help='Check ZyCAP build dependencies.')
@click.option('--clean', is_flag=True, help='Check ZyCAP build dependencies.')
def run(config,deps,clean):
    if deps is False:
        deps = None
    z = fpga(json=config,deps=deps,clean=clean)
    z.run_tooling()


if __name__ == '__main__':
    run()