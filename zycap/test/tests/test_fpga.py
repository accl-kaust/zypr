from zycap.fpga import Build as FPGA
from zycap.utils import logging
import sys
from pathlib import Path
import pytest


logger = logging.init_logger(
    __name__, verbose=True, testing_mode=True)
f = FPGA(json="demo/test.json", logger=logger, force=True)
f.protocol_dict = {'SIGNAL': {'CLOCK': [['clk']], 'INTERRUPT': [['irq']], 'GPIO_IN': [['gpio']]}, 'AXI': {'STREAM_MASTER': [['b_TDATA_out', 'b_TVALID', 'b_TREADY']], 'STREAM_SLAVE': [['a_TDATA_in', 'a_TVALID', 'a_TREADY']]}}
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

@pytest.mark.xfail(reason="Need to fix edalize")
def test_gen_infra():
    assert f._Build__gen_infrastructure() == True

def test_gen_permutations():
    region_a = ['config_a','config_b','config_c']
    region_b = ['config_a','config_b','config_c']
    region_c = ['config_a','config_b']

    for perm in f._Build__gen_prr_permutations(region_a,region_b,region_c):
        assert perm != 'config_c'
        
    assert f._Build__gen_prr_permutations(region_a,region_b,region_c) == [('config_a', 'config_a', 'config_a'),
                                                                        ('config_a', 'config_a', 'config_b'), 
                                                                        ('config_a', 'config_c', 'config_a'), 
                                                                        ('config_a', 'config_c', 'config_b'), 
                                                                        ('config_b', 'config_b', 'config_b'), 
                                                                        ('config_b', 'config_c', 'config_b')]
    logger.info(f'Tearing down directories - ({Path.cwd()})')

