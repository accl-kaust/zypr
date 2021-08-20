from .tool import Tool
import click, click_spinner
import subprocess
from packaging import version

YOSYS_VERSION = "0.9"
DOCKER_VERSION = "20.10.0"

class Setup(Tool):
    def __init__(self,config,boards):  
        print(config)
        self.status = False
        self.install_dependencies()  

    def install_dependencies(self):
        click.secho('checking dependencies...', fg='yellow')      

        if all(
            [
                self.check_yosys(),
                self.check_docker(),
            ]
        ):
            self.status = True

    def install_boards(self):
        pass

    def check_yosys(self):
        s = subprocess.Popen(
            'yosys -V'.split(), stdout=subprocess.PIPE)
        out, err = s.communicate()
        success = False
        if err != None:
            click.echo(err)
            success = self.install_yosys()
        else:
            found = out.decode('ascii').split()[1]
            if version.parse(found) < version.parse(YOSYS_VERSION):
                click.secho(f'Found Yosys version {found}, installing latest...',fg='yellow')
                success = self.install_yosys()
            else:
                click.secho(f"Yosys {found} installed.",fg='green')
                success = True
        return success

    def install_yosys(self):
        p0 = subprocess.Popen(
            'git clone git@github.com:YosysHQ/yosys.git .yosys'.split(), stdout=subprocess.DEVNULL)

        cmd1 = 'cd .yosys'
        cmd2 = 'make config-gcc -j 10'
        cmd3 = 'make -j 10'

        with subprocess.Popen("{}; {}; {}".format(cmd1, cmd2,cmd3), shell=True, stdin=subprocess.PIPE, 
                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True) as sp:
            for line in sp.stdout:
                print(line)

        click.secho("Yosys installed.",fg='green')
        return True

    def check_docker(self):
        s = subprocess.Popen(
            "docker version --format '{{.Server.Version}}'".split(), stdout=subprocess.PIPE)
        out, err = s.communicate()
        success = False
        if err != None:
            click.echo(err)
            success = self.install_docker()
        else:
            found = out.decode('ascii').split("'")[1]
            if version.parse(found) < version.parse(DOCKER_VERSION):
                click.secho(f'Found Docker version {found}, installing latest...',fg='yellow')
                success = self.install_docker()
            else:
                click.secho(f"Docker {found} installed.",fg='green')
                success = True
        return success

    def install_docker(self):
        return True

    def create_config(self):
        pass