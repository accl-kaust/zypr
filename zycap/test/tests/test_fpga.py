from zycap.fpga import Build as fpga
from zycap.utils import logging
import sys


logger = logging.init_logger(
    __name__, verbose=True, testing_mode=True)
f = fpga(json="demo/config.json", logger=logger, force=True)


def test_example():
    assert True == True


def test_gen_infra():
    assert f._Build__gen_infrastructure() == True
