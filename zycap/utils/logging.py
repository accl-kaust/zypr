import logging
import colorlog
import sys
from os import path, makedirs, remove, listdir, walk
from shutil import rmtree
import glob
import re

# def setup_logger():
#     """Return a logger with a default ColoredFormatter."""
#     formatter = ColoredFormatter(
#         "%(log_color)s%(levelname)-8s%(reset)s %(blue)s%(message)s",
#         datefmt=None,
#         reset=True,
#         log_colors={
#             'DEBUG':    'cyan',
#             'INFO':     'green',
#             'WARNING':  'yellow',
#             'ERROR':    'red',
#             'CRITICAL': 'red',
#         }
#     )

#     logger = logging.getLogger('example')
#     handler = logging.StreamHandler()
#     handler.setFormatter(formatter)
#     logger.addHandler(handler)
#     logger.setLevel(logging.DEBUG)

#     return logger


def init_logger(dunder_name, testing_mode, verbose=False) -> logging.Logger:
    log_format = (
        '%(levelname)5s - '
        '%(asctime)8s - '
        '%(module)8s - '
        '%(funcName)22s - '
        '%(message)s'
    )
    bold_seq = '\033[1m'
    colorlog_format = (
        f'{bold_seq} '
        '%(log_color)s '
        f'{log_format}'
    )
    colorlog.basicConfig(format=colorlog_format,datefmt="%H:%M:%S")
    logger = logging.getLogger(dunder_name)

    if not path.exists('.logs'):
        makedirs('.logs')

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
    else:
        logger.propagate = True

    return logger

# def clean(dir, pattern):
#     for f in listdir(dir):
#         if re.search(pattern, f):
#             remove(path.join(dir, f))

def clean(path, exts):
    for root, dirs, files in walk(path):
        for currentFile in files:
            if currentFile.lower().endswith(exts):
                print(f"removing file: {currentFile}")
                remove(path.join(root, currentFile))