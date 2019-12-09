################################################################
# Add Black Box for PR Modules
################################################################

add_files $origin_dir/rtl/.blackbox/$top_mod_file

update_compile_order -fileset sources_1

create_bd_cell -type module -reference partial_led_test_v1_0 partial_led_test_v1_0_0

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_slave {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Clk_xbar {/zynq_ultra_ps_e_0/pl_clk0 (100 MHz)} Master {/zynq_ultra_ps_e_0/M_AXI_HPM0_FPD} Slave {/partial_led_test_v1_0_0/s00_axi} intc_ip {/ps8_0_axi_periph} master_apm {0}}  [get_bd_intf_pins partial_led_test_v1_0_0/s00_axi]

create_bd_port -dir O -from 7 -to 0 leds

connect_bd_net [get_bd_ports leds] [get_bd_pins partial_led_test_v1_0_0/leds]
