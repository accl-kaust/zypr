# Module: test
# File:   build/.inst/test.tcl
# Date:   23:11 28/01/2021
# Type:   tcl
# DO NOT MODIFY THIS FILE; AUTOMATICALLY GENERATED BY INTERFACER

create_project -part xczu3eg-sbva484-1-e -in_memory
read_ip rtl/test.xci
generate_target instantiation_template [get_files rtl/test.xci]
close_project
exit