from ..fpga import build as f
from ..linux import build as l
import click

@click.option('--config','-c', default=None, help='Specify configuration file.')
@click.option('--deps','-d', is_flag=True, help='Install ZyCAP dependencies.')
@click.option('--clean', is_flag=True, help='Clean ZyCAP build meta.')
@click.option('--fpga','-f', is_flag=True, help='Build for only FPGA.')
@click.option('--linux','-l', is_flag=True, help='Build for only Linux.')
@click.command()
def cli(config,deps,clean,fpga,linux):
    if deps is False:
        deps = None
    z = f(json=config,deps=deps,clean=clean)
    z.run_tooling()
