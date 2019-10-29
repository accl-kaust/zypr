use Verilog::Netlist;
 
# Setup options so files can be found
use Verilog::Getopt;
my $opt = new Verilog::Getopt;
$opt->parameter( "+incdir+verilog",
                 "-y","verilog",
                 );
my @rtlfiles =glob("*.v");
foreach my $rtlfiles (@rtlfiles)
{
  print("$rtlfiles\n");
}
# print(@things);
$opt->library(@rtlfiles);
 
# Prepare netlist
my $nl = new Verilog::Netlist(options => $opt);
foreach my $file ('test.v') {
    $nl->read_file(filename=>$file);
}
# Read in any sub-modules
$nl->link();
#$nl->lint();  # Optional, see docs; probably not wanted
$nl->exit_if_error();
 
foreach my $mod ($nl->top_modules_sorted) {
    show_hier($mod, "  ", "", "");
}
 
sub show_hier {
    my $mod = shift;
    my $indent = shift;
    my $hier = shift;
    my $cellname = shift;
    if (!$cellname) {$hier = $mod->name;} #top modules get the design name
    else {$hier .= ".$cellname";} #append the cellname
    printf("%-45s %s\n", $indent."Module ".$mod->name,$hier);
    foreach my $sig ($mod->ports_sorted) {
        printf($indent."      %sput %s\n", $sig->direction, $sig->name);
    }
    foreach my $cell ($mod->cells_sorted) {
        printf($indent. "    Cell %s\n", $cell->name);
        foreach my $pin ($cell->pins_sorted) {
            printf($indent."     .%s(%s)\n", $pin->name, $pin->netname);
        }
        show_hier($cell->submod, $indent."   ", $hier, $cell->name) if $cell->submod;
    }
}