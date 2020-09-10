from ..fpga import build as f
from ..linux import build as l
from ..utils import logging   
import click
logger = logging.init_logger(__name__, testing_mode=True)

@click.option('--clean', is_flag=True, help='Clean ZyCAP build meta.')
@click.option('--deps','-d', is_flag=True, help='Install ZyCAP dependencies.')
@click.option('--log','-lg', is_flag=True, help='Enable logging.')
@click.option('--linux','-l', is_flag=True, help='Build for only Linux.')
@click.option('--fpga','-f', is_flag=True, help='Build for only FPGA.')
@click.option('--config','-c', default=None,metavar='<config.json>', help='Specify configuration file.')
@click.command()
def cli(config,deps,clean,fpga,linux,log):
    """ZyCAP PR Build and Runtime Tooling. Visit https://github.com/warclab/zycap for more information."""
    if deps is False:
        deps = None
    z = f(json=config,deps=deps,clean=clean,logger=logger)
    z.run_tooling()
