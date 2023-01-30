from nmigen import *
from nmigen.build import Platform

class Blinky(Elaboratable):
    def __init__(self):
        self.clk = ClockSignal()
        self.led = Signal()


    def elaborate(self, platform: Platform) -> Module:
        m = Module()
        count = Signal(32)

        with m.If(count == 500000000):
            m.d.sync += count.eq(0)
            m.d.sync += self.led.eq(~self.led)
        with m.Else():
            m.d.sync += count.eq(count + 1)

        return m

from nmigen.cli import main

if __name__ == "__main__":
    blinky = Blinky()
    axis_m_data = Signal()
    main(blinky, name='blink', ports=[blinky.clk, blinky.led])