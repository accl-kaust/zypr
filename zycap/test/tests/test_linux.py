from zycap.linux import Build as linux
from zycap.utils import logging
import sys
from pathlib import Path


logger = logging.init_logger(
    __name__, verbose=True, testing_mode=True)
f = fpga(json="demo/config.json", logger=logger, force=True)
f.xilinx_version = '2019.2'

def setup_function():
    logger.info('Setting up directories')

    path = Path.cwd() / 'rtl' / ".inst"
    try:
        path.mkdir(parents=True, exist_ok=False)
    except FileExistsError:
        print("Folder is already there")
    else:
        print("Folder was created")

    for f in Path('.').glob('*.v'):
        logger.info(f)
        try:
            f.unlink()
        except OSError as e:
            print("Error: %s : %s" % (f, e.strerror))


def test_gen_infra():
    assert f._Build__gen_infrastructure() == True


def teardown_function():
    logger.info(f'Tearing down directories - ({Path.cwd()})')

