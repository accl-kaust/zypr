set net_list [get_bd_pins -hierarchical]
set cell_list [get_bd_ports]

foreach i $net_list {
    set ctr 0

    foreach j $cell_list { 
        set x [get_bd_pins -of_objects [get_bd_ports $j]]
        set y $i
        if { $y==$x } {
            incr ctr
            puts "$i connected to $j\n"
            puts "$ctr\n"
        }			
    }	 
    if { $ctr==0 } {
        #incr ctr
        puts "$i is free"
    }	
}