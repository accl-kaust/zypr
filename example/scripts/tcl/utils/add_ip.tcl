
# set proj "/home/alex/GitHub/zycap2/example/ip_cores"
# set ip_cores [get_ips]


proc generate_ip {location} {
    set ip_dirs [glob -directory $location -type d *]
    set ip_cores {}
    foreach dir $ip_dirs {
        lappend ip_cores [glob -directory $dir *.xci]
    }
    puts $ip_cores

    foreach ip $ip_cores {
        puts "Generating $ip core"

        set ip_base [file rootname [file tail $ip]]
        puts $ip_base

        read_ip $ip

        #Step 2: Check if IP is locked
        set locked [get_property IS_LOCKED [get_ips $ip_base]]

        #Step 3: Check if upgrade is available
        set upgrade [get_property UPGRADE_VERSIONS [get_ips $ip_base]]

        #Step 4: Upgrade IP if required
        if {$locked && $upgrade != ""} {
        upgrade_ip [get_ips $ip_base]}

        #Step 5: Produce IP output products
        generate_target all [get_ips $ip_base]
    }
}



