import fire
import os

class Config(object):
  """Config"""
  def __init__(self, json='global_config.json'):
    self.config = json

  def get(self):
    return self.config

  def set(self, json='global_config.json'):
    self.config = json


class Vivado(object):
  """Vivado Controls"""
  def __init__(self):
    self.completed = {
      "vivado": {
        "blackbox": False,
        "pr_modules": False,
      },
      "petalinux": {
        "build": False,
        "config": False,
        "package": False
      }
    }

  def synth(self, number):
    """Generate Synthesis Runs for Project"""
    return 2 * number
  def prepare(self, number):
    """Generate Verilog Structure for Project"""
    return 4 * number

class Petalinux(object):
  """Petalinux Controls"""

  def build(self, function='build', stage=0):
    return stage

class Zycap(object):
  """ZyCAP CLI"""
  def __init__(self):
    self.vivado = Vivado()
    self.linux = Petalinux()
    self.config = Config()

  """Generate Builder for ZyCAP Project"""
  def build(self, stage=0):
    return stage

if __name__ == '__main__':
  fire.Fire(Zycap)