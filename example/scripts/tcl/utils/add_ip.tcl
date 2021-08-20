
# set proj "${location}/ip_cores"
# set ip_cores [get_ips]


proc generate_ip {location} {
    set ip_dirs [glob -directory "${location}/.ip_cores" -type d *]
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
        generate_target all [get_files $ip]
        catch { config_ip_cache -export [get_ips -all $ip_base] }
        export_ip_user_files -of_objects [get_files $ip] -no_script -sync -force -quiet
        create_ip_run [get_files -of_objects [get_fileset sources_1] $ip] -force
        export_simulation -of_objects [get_files $ip] -directory "${location}/rtl/.checkpoint_prj/system_top.ip_user_files/sim_scripts" -ip_user_files_dir "${location}/rtl/.checkpoint_prj/system_top.ip_user_files" -ipstatic_source_dir "${location}/rtl/.checkpoint_prj/system_top.ip_user_files/ipstatic" -force -quiet

        launch_runs -jobs 7 ${ip_base}_synth_1
        wait_on_run ${ip_base}_synth_1

    }
    update_compile_order -fileset sources_1
}

# export_simulation -of_objects [get_files /home/alex/GitHub/zycap2/example/rtl/.modes/mode_a/config_a/.ip_cores/xfft_mode_a/xfft_mode_a.xci] -directory /home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.ip_user_files/sim_scripts -ip_user_files_dir /home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.ip_user_files -ipstatic_source_dir /home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.ip_user_files/ipstatic -lib_map_path [list {modelsim=/home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.cache/compile_simlib/modelsim} {questa=/home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.cache/compile_simlib/questa} {ies=/home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.cache/compile_simlib/ies} {xcelium=/home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.cache/compile_simlib/xcelium} {vcs=/home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.cache/compile_simlib/vcs} {riviera=/home/alex/GitHub/zycap2/example/rtl/.checkpoint_prj/system_top.cache/compile_simlib/riviera}] -use_ip_compiled_libs -force -quiet


