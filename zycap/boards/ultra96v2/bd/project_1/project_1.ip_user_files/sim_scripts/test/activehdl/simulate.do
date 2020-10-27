onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+test -L xilinx_vip -L axi_infrastructure_v1_1_0 -L axi_vip_v1_1_6 -L zynq_ultra_ps_e_vip_v1_0_6 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.test xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {test.udo}

run -all

endsim

quit -force
