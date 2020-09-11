import logging
import colorlog
import os
import glob

def init_logger(dunder_name, testing_mode, verbose=False) -> logging.Logger:
    log_format = (
        '%(levelname)s - '
        '%(asctime)s - '
        '%(module)s - '
        '%(funcName)s - '
        '%(message)s'
    )
    bold_seq = '\033[1m'
    colorlog_format = (
        f'{bold_seq} '
        '%(log_color)s '
        f'{log_format}'
    )
    colorlog.basicConfig(format=colorlog_format)
    logger = logging.getLogger(dunder_name)

    if not os.path.exists('.logs'):
        os.makedirs('.logs')

    if testing_mode:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    # Output full log
    fh = logging.FileHandler('.logs/{}.log'.format(dunder_name))
    fh.setLevel(logging.INFO)
    formatter = logging.Formatter(log_format)
    fh.setFormatter(formatter)
    logger.addHandler(fh)

    # Output warning log
    fh = logging.FileHandler('.logs/{}.warning.log'.format(dunder_name))
    fh.setLevel(logging.WARNING)
    formatter = logging.Formatter(log_format)
    fh.setFormatter(formatter)
    logger.addHandler(fh)

    # Output error log
    fh = logging.FileHandler('.logs/{}.error.log'.format(dunder_name))
    fh.setLevel(logging.ERROR)
    formatter = logging.Formatter(log_format)
    fh.setFormatter(formatter)
    logger.addHandler(fh)

    if verbose is False:
        logger.propagate = False

    return logger

def clean():
    files = glob.glob('.logs/*.log')
    for f in files:
        os.remove(f)