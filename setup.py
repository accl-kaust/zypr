import os
from setuptools import setup, find_packages, find_namespace_packages
from setuptools.command.develop import develop
from subprocess import run, DEVNULL


def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()


class PreInstallCommand(develop):
    """Pre-installation for installation mode."""

    def run(self):
        install_commands = [
            "sudo apt install yosys -y",
            "sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release",
            "sudo apt install -y docker-ce docker-ce-cli containerd.io"
        ]
        for each in install_commands:
            out = self.install(each)
            if out != None:
                exit(f"Failed installation: {out}")
        develop.run(self)

    def install(self, command):
        print("Installing...")
        output = run(command.split(), stdout=DEVNULL)
        if output.returncode != 0:
            return(output)

    def docker(self):
        print("Attempting to install docker tools, requires sudo.")
        # return check_output(
        #     .split())


setup(
    name="zypr",
    version="0.0.2",
    packages=find_packages(),
    cmdclass={
        'develop': PreInstallCommand,
    },
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
    package_dir={
        'zypr': 'zypr',
    },
    include_package_data=True,
    py_modules=['zypr'],
    author="Alex Bucknall",
    author_email="alex.bucknall@gmail.com",
    description=(
        "ZyPR is an end-to-end partial reconfiguration CLI for build and runtime control of adaptive applications on the Xilinx Zynq and Zynq Ultrascale+ SoCs"),
    license="BSD",
    keywords=["verilog", "EDA", "hdl", "rtl", "synthesis",
              "FPGA", "Xilinx", "Partial Reconfiguration"],
    url="https://github.com/accl-kaust/zypr",
    long_description=read('README.md'),
    long_description_content_type='text/markdown',
    classifiers=[
        "Development Status :: 4 - Beta",
        "License :: OSI Approved :: BSD License",
        "Operating System :: POSIX :: Linux",
        "Topic :: Scientific/Engineering :: Electronic Design Automation (EDA)",
        "Topic :: Utilities",
    ],
    install_requires=[
        'xmltodict',
        'edalize >= 0.2.5',
        'nmigen',
        'fdt',
        'Click',
        'click-log',
        'click-spinner',
        'colorlog',
        'nmigen',
        'docker',
        'regex',
        'click-help-colors',
        'pyverilog==1.2.1',
        'mkdocs',
        'mkdocs-click',
        'mkdocs-wavedrom-plugin',
        'mkdocs-monorepo-plugin',
        'mkdocs-material',
        'mkdocs-bibtex',
        'pytest>=3.3.0',
        'Jinja2 >=2.8, !=2.11.0, !=2.11.1',
    ],
    tests_require=[
        'vunit_hdl>=4.0.8'
    ],
    entry_points='''
        [console_scripts]
        zypr=zypr.scripts.cli:cli
    ''',
    # Supported Python versions: 3.7+
    python_requires=">=3.7, <4",
)
