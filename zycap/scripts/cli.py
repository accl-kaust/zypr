from ..fpga import build as f
from ..linux import build as l
from ..utils import logging   
import click
from click_help_colors import HelpColorsGroup, HelpColorsCommand
import subprocess
import pkg_resources
from distutils.dir_util import copy_tree
import os
from shutil import rmtree

@click.group(
    cls=HelpColorsGroup,
    help_headers_color='yellow',
    help_options_color='green',
    help_options_custom_colors={'run': 'green', 'docs': 'blue', 'setup': 'blue','clean':'red'},
    chain=True
)
@click.option('--verbose','-v', is_flag=True, help='Enable logging.')
@click.pass_context
def cli(ctx,verbose):
    """ZyCAP PR Build and Runtime Tooling. Visit https://github.com/warclab/zycap for more information."""
    ctx.ensure_object(dict)
    ctx.obj['LOG'] = logging.init_logger(__name__, verbose=verbose, testing_mode=True)

@click.option('--linux','-l', is_flag=True, help='Build for only Linux.')
@click.option('--fpga','-f', is_flag=True, help='Build for only FPGA.')
@click.option('--config','-c', default=None,metavar='<config.json>', help='Specify configuration file.')
@cli.command()
@click.pass_context
def run(ctx,config,fpga,linux):
    """Run - start ZyCAP design processes"""
    logger = ctx.obj['LOG']
    if fpga:
        z = f(json=config,logger=logger)
        logger.info('FPGA')
    elif linux:
        z = l(json=config)
        logger.info('Linux')
    else:
        z = f(json=config,logger=logger, linux=True)
        logger.info('E2E')
    # z.run()

@click.option('--deps','-d', is_flag=True, help='Install ZyCAP dependencies.')
@click.option('--docker', default=None,metavar='<version>', help='Generate Docker Environment. Specify Xilinx Tool Version, i.e. 2019.1.')
@cli.command()
@click.pass_context
def setup(ctx,docker,deps):
    """Setup - setup build environment"""
    logger = ctx.obj['LOG']
    if deps is False:
        deps = None
    logger.info('setting up')

@click.option('--linux','-l', is_flag=True, help='Clean only Linux.')
@click.option('--fpga','-f', is_flag=True, help='Clean only FPGA.')
@click.option('--logs', is_flag=True, help='Cleans logs.')
@cli.command()
@click.pass_context
def clean(ctx,linux,fpga,logs):
    """Clean - cleans build environment"""
    logger = ctx.obj['LOG']
    logger.info('cleaning')
    if logs:
        logging.clean()

@click.option('--device','-d', default='Ultra96v2', help='Sets device to be flashed.')
@cli.command()
@click.pass_context
def flash(ctx,linux,fpga):
    """Flash - flashes attached device"""
    logger = ctx.obj['LOG']
    logger.info('flashing')

@click.option('--clean','-c', is_flag=True, help='Clean docs.')
@cli.command()
@click.pass_context
def docs(ctx,clean):
    """Docs - serve documentation"""
    logger = ctx.obj['LOG']
    if clean:
        if os.path.exists('.docs'):
            rmtree('.docs')
        return
    docs = pkg_resources.resource_filename('zycap', 'docs')
    if not os.path.exists('.docs'):
        copy_tree(docs, '.docs')
    else:
        logger.error('docs already exist')
    process = subprocess.Popen('mkdocs serve -f .docs/mkdocs.yml'.split(), stdout=subprocess.PIPE)
    _, error = process.communicate()
    if error:
        logger.info()