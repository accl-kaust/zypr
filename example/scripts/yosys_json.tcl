# yosys -import
# set json ".json"
# read_verilog $argv
# hierarchy; proc; flatten;
# write_json $argv$json
package require fileutil

set json_dir "/.json/"

proc is_log {name} {
    return [string match *.v $name]
}

cd "../"
set log_files [fileutil::find [pwd] is_log]

foreach file $log_files {
    puts "There's a file: $file"
    set dir [file dirname $file]    
    set fi [file tail $file]    
    exec mkdir -p $dir$json_dir
    exec yosys -p "read_verilog $file; hierarchy; proc; flatten; write_json $dir$json_dir[string trimright $fi ".v"].json"
}