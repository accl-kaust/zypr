#!/usr/bin/tclsh

set app_name          "pmufw"
set app_type          "zynqmp_pmufw"
set project_name      [lindex $argv 0] 
set hwspec_file       "${project_name}.xsa"
set proc_name         "psu_pmu_0"
set project_dir       [file join [pwd] [lindex $argv 1]]
set sdk_workspace     [file join $project_dir "${project_name}.sdk"]
set app_dir           [file join $sdk_workspace $app_name]
set app_release_dir   [file join [pwd] ".." ]
set app_release_elf   "pmufw.elf"
set board_shutdown    true
set secure_access     true
set board_power_sw    true
set hw_design         [hsi::open_hw_design [file join $sdk_workspace $hwspec_file]]

hsi::generate_app -hw $hw_design -os standalone -proc $proc_name -app $app_type -dir $app_dir

if {$board_shutdown || $board_power_sw || $secure_access} {
    file copy -force [file join $app_dir "xpfw_config.h"] [file join $app_dir "xpfw_config.h.org"] 
    set xpfw_config_old [open [file join $app_dir "xpfw_config.h.org"]  r]
    set xpfw_config_new [open [file join $app_dir "xpfw_config.h.new"]  w]
    while {[gets $xpfw_config_old line] >= 0} {
        if       {$board_shutdown && [regexp {^#define\s+BOARD_SHUTDOWN_PIN_VAL\s+\S+}       $line]} {
	    puts $xpfw_config_new "#define BOARD_SHUTDOWN_PIN_VAL       (1U)"
        } elseif {$board_shutdown && [regexp {^#define\s+BOARD_SHUTDOWN_PIN_STATE_VAL\s+\S+} $line]} {
            puts $xpfw_config_new "#define BOARD_SHUTDOWN_PIN_STATE_VAL (1U)"
        } elseif {$board_power_sw && [regexp {^#define\s+PMU_MIO_INPUT_PIN_VAL\s+\S+}        $line]} {
            puts $xpfw_config_new "#define PMU_MIO_INPUT_PIN_VAL        (1U)"
        } elseif {$secure_access && [regexp {^#define\s+SECURE_ACCESS_VAL\s+\S+}            $line]} {
            puts $xpfw_config_new "#define SECURE_ACCESS_VAL        (1U)"
        } else {
            puts $xpfw_config_new $line
        }
    }
    close $xpfw_config_old
    close $xpfw_config_new
    file rename -force [file join $app_dir "xpfw_config.h.new"] [file join $app_dir "xpfw_config.h"] 
}

exec make -C $app_dir all >&@ stdout

file copy -force [file join $app_dir "executable.elf"] [file join $sdk_workspace $app_release_elf]