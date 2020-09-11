from tool import tool

class setup(tool):
    def __init__(self,deps=None):  
        if deps is None:
            self.check_dependencies = self.config['config']['config_settings']['check_dependencies']
        else:
            self.check_dependencies = deps
            click.secho('checking dependencies...', fg='yellow')        
        pass

    def install_dependencies(self):
        # Python
        # subprocess.check_call([sys.executable, "-m", "pip", "install", "-r","requirements.txt"])
        # Perl (to be deprecated)
        pass


    def install_boards(self):
        pass