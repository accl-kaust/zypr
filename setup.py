import os
from setuptools import setup, find_packages


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


setup(
    name="zycap",
    version="0.0.1",
    packages=find_packages(),
    package_data={
        'fpga': [
            'config/global.json',
            'ip/*'
        ],
        'linux': [
            'drivers/*'
        ],
        'boards': [
            'boards/*',
        ],
        'docs': [
            'mkdocs.yml',
            'docs/*'
        ],
        'scripts': [
            'vivado/*',
            'vitis/*'
        ]},
    include_package_data=True,
    py_modules=['zycap', 'interfacer'],
    author="Alex Bucknall",
    author_email="alex.bucknall@gmail.com",
    description=(
        "ZyCAP is a Partial Reconfiguration build tool and runtime framework for Xilinx Zynq and Zynq Ultrascale+ SoCs"),
    license="MIT",
    keywords=["verilog", "EDA", "hdl", "rtl", "synthesis",
              "FPGA", "Xilinx", "Partial Reconfiguration"],
    url="https://github.com/warclab/zycap2",
    long_description=read('README.md'),
    classifiers=[
        "Development Status :: 4 - Beta",
        "License :: OSI Approved :: MIT License",
        "Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)",
        "Topic :: Utilities",
    ],
    install_requires=[
        'xmltodict',
        'edalize',
        'nmigen',
        'fdt',
        'Click',
        'click-log',
        'click-spinner',
        'colorlog',
        'nmigen',
        'docker',
        'click-help-colors',
        'pyverilog==1.2.1',
        'mkdocs>=1.1',
        'mkdocs-wavedrom-plugin==0.1.1',
        'mkdocs-monorepo-plugin>=0.4.2',
        'mkdocs-material',
        'mkdocs-bibtex==0.2.3',
        'pytest>=3.3.0',
        'Jinja2 >=2.8, !=2.11.0, !=2.11.1',
    ],
    tests_require=[
        'vunit_hdl>=4.0.8'
    ],
    entry_points='''
        [console_scripts]
        zycap=zycap.scripts.cli:cli
    ''',
    # Supported Python versions: 3.5+
    python_requires=">=3.5, <4",
)
