
set ip_store [lindex $argv 0]
set icap_version [lindex $argv 1]

add_files -norecurse $ip_store/ip/icap/$icap_version

update_compile_order -fileset sources_1
create_bd_cell -type module -reference icap icap_0