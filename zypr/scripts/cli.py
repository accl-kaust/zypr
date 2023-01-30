# scripts/cli.py
from ..fpga import Build as f
from ..linux import Build as l
from ..utils import logging
from ..utils import setup as s
from click_help_colors import HelpColorsGroup, HelpColorsCommand
import click
import subprocess
import pkg_resources
from distutils.dir_util import copy_tree
from os import path, symlink, unlink
from pathlib import Path
import time


@click.group(
    cls=HelpColorsGroup,
    help_headers_color='yellow',
    help_options_color='green',
    help_options_custom_colors={
        'run': 'green', 'install': 'blue', 'docs': 'blue', 'setup': 'blue', 'clean': 'magenta'},
    chain=True
)
@click.option('--verbose', '-v', is_flag=True, help='Enable logging.')
@click.pass_context
def cli(ctx, verbose):
    """ZyPR PR Build and Runtime Tooling. Visit https://github.com/accl-kaust/zypr for more information."""
    ctx.ensure_object(dict)
    ctx.obj['LOG'] = logging.init_logger(
        __name__, verbose=verbose, testing_mode=True)


@click.option('--linux', is_flag=True, help='Build for only Linux.')
@click.option('--fpga', is_flag=True, help='Build for only FPGA.')
@click.option('--force', '-f', is_flag=True, default=False, help='Overwrite existing build files')
@click.option('--config', '-c', default=None, metavar='<config.json>', help='Specify configuration file.')
@cli.command()
@click.pass_context
def run(ctx, config, fpga, linux, force):
    """start ZyPR build processes"""
    logger = ctx.obj['LOG']
    start_time = time.time()
    if fpga:
        z = f(json=config, logger=logger, force=force)
        logger.info('FPGA')
        z.run()
    elif linux:
        z = l(json=config, logger=logger, force=force)
        logger.info('Linux')
        z.run()
    else:
        z = f(json=config, logger=logger, force=force)
        logger.info('E2E')
        z_l = l(json=config, logger=logger)
        z.run()
        z_l.run()
    print("Completed in %s seconds" % (time.time() - start_time))


@click.option('--deps', '-d', is_flag=True, help='Install ZyPR dependencies.')
@click.option('--docker', default=None, metavar='<version>', help='Generate Docker Environment. Specify Xilinx Tool Version, i.e. 2019.1.')
@cli.command()
@click.pass_context
def setup(ctx, docker, deps):
    """setup build environment"""
    logger = ctx.obj['LOG']
    if deps is False:
        deps = None
    logger.info('setting up')


@click.option('--linux', '-l', is_flag=True, help='Clean only Linux.')
@click.option('--fpga', '-f', is_flag=True, help='Clean only FPGA.')
@click.option('--logs', is_flag=True, help='Cleans logs.')
@cli.command()
@click.pass_context
def clean(ctx, linux, fpga, logs):
    """cleans build environment"""
    logger = ctx.obj['LOG']
    logger.info('cleaning')
    if logs:
        logging.clean(Path.cwd(), ('.log', '.jou', '.str'))


@click.option('--device', '-d', default='Ultra96v2', help='Sets device to be flashed.')
@cli.command()
@click.pass_context
def flash(ctx, linux, fpga):
    """flashes attached device"""
    logger = ctx.obj['LOG']
    logger.info('flashing')


@click.option('--clean', '-c', is_flag=True, help='Clean docs.')
@cli.command()
@click.pass_context
def docs(ctx, clean):
    """serve documentation"""
    logger = ctx.obj['LOG']
    if clean:
        if path.exists('.docs'):
            unlink('.docs')
        return
    docs = pkg_resources.resource_filename('zypr', 'docs')
    if not path.exists('.docs'):
        symlink(docs, '.docs')
    else:
        logger.error('docs already exist')
    process = subprocess.Popen(
        'mkdocs serve -f mkdocs.yml'.split(), stdout=subprocess.PIPE)
    _, error = process.communicate()
    if error:
        logger.info()


@cli.command()
@click.pass_context
@click.option('--config', default="$HOME/.zypr.json")
@click.option('--boards', default="ultra96v2")
def install(ctx, config, boards):
    """install dependencies for ZyPR"""
    click.secho(f"Installing from config at {config}", fg='yellow')
    setup = s.Setup(config, boards)
    if setup.status == True:
        click.secho("All dependencies installed.", fg='green')
    pass
