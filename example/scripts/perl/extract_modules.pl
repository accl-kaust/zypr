use Verilog::Netlist;
use strict;
use warnings;
use 5.010;
use Scalar::Util qw(looks_like_number);
use Math::Calc::Parser 'calc';
binmode STDOUT, ":utf8";
use utf8;
use Try::Tiny;
use Data::Dumper qw(Dumper);
use JSON;
# Setup options so files can be found
use Verilog::Getopt;
use File::Find;
use File::Basename;

my $working_dir = $ARGV[0];
my %json_data; 
my $nl;
my $opt = new Verilog::Getopt;
$opt->parameter( "+incdir+verilog",
                 "-y","verilog",
                 );

my @rtlfiles =glob("$working_dir/*.v");
foreach my $rtlfiles (@rtlfiles)
{
  print("$rtlfiles\n");
}
# print(@things);
$opt->library(@rtlfiles);


my @dirs = (".");
my %seen;
while (my $pwd = shift @dirs) {
        opendir(DIR,"$pwd") or die "Cannot open $pwd\n";
        my @files = readdir(DIR);
        closedir(DIR);
        print "$pwd";
        foreach my $file (@files) {
                next if $file =~ /^\.\.?$/;
                my $path = "$pwd/$file";
                if (-d $path) {
                        next if $seen{$path};
                        $seen{$path} = 1;
                        push @dirs, $path;
                }
                next if ($path !~ /\.v$/i);
                undef %json_data;
                undef $nl;
                my $mtime = (stat($path))[9];
                print "File found: $path | $pwd\n";
                $nl = new Verilog::Netlist(options => $opt,);
                $nl->read_file(filename=>$path);
                $json_data{"FILE_NAME"} = basename($path);
                # Read in any sub-modules
                $nl->link();
                # $nl->lint();  # Optional, see docs; probably not wanted
                $nl->exit_if_error();

                foreach my $mod ($nl->top_modules_sorted) {
                    show_hier($mod, "  ", "", "");
                }

                my $myHashEncoded = JSON->new->pretty->encode(\%json_data);
                my $name_file = substr(basename($path), 0, -2);
                my $existingdir = "$pwd/.json";
                mkdir $existingdir unless -d $existingdir; # Check if dir exists. If not create it.
                open my $fh, ">", "$existingdir/$name_file.json" or die "Can't open '$existingdir/$name_file.json'\n";
                print $fh $myHashEncoded;
                close $fh;
        }
}
 
sub show_hier {
    my $mod = shift;
    my $indent = shift;
    my $hier = shift;
    my $cellname = shift;
    if (!$cellname) {
        $json_data{'TOP_MODULE'} = $mod->name;
        } #top modules get the design name
    else {
        $hier .= ".$cellname";
        } #append the cellname
    foreach my $cont ($mod->nets){
        if($cont->decl_type eq "parameter"){
            $json_data{'MODULE'}{$mod->name}{'PARAMETER'}{$cont->name} = $cont->value;
        }
        if($cont->decl_type eq "localparam"){
            $json_data{'MODULE'}{$mod->name}{'LOCALPARAM'}{$cont->name} = $cont->value;
        }
    }
    my %ports;
    foreach my $sig ($mod->ports_sorted) {
            $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'DIRECTION'} = $sig->direction."put";
            if($mod->find_net($sig->name)->data_type =~ /.[a-z]+/i){
                foreach my $params ($json_data{'MODULE'}{$mod->name}{'PARAMETER'}){
                    foreach my $param (keys %$params) {
                    }
                }
                foreach my $params ($json_data{'MODULE'}{$mod->name}{'LOCALPARAM'}){
                    foreach my $param (keys %$params) {
                    }
                }

                my $width = $mod->find_net($sig->name)->data_type;
                my $result_a; 
                my $result_b;
                if ( $width =~ /\[(.*?)\:/ )
                {
                    $result_a = replace_param($1,$mod->name);
                }
                if ( $width =~ /\:(.*?)\]/ )
                {
                    $result_b = replace_param($1,$mod->name);
                }
                $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = (($result_a+1)-$result_b);
            }
            else{
                if (defined $mod->find_net($sig->name)->width)
                {
                    $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = $mod->find_net($sig->name)->width;
                }
                else
                {
                    $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = 1;
                }
            }            
    }
    foreach my $cell ($mod->cells_sorted) {
        foreach my $pin ($cell->pins_sorted) {
        }
        show_hier($cell->submod, $indent."   ", $hier, $cell->name) if $cell->submod;
    }
}

sub replace_param {
    my $arg = shift;
    my $mod = shift;
    try {
        my $result = calc $arg;
        return $result;
    } 
    catch {
        my $inside = $arg;
        my %compare_param = %{$json_data{'MODULE'}{"$mod"}{'PARAMETER'}};
        for (sort keys %compare_param) {
            $inside =~ s/$_/$compare_param{$_}/eig;
        } 
        my %compare_localparam = %{$json_data{'MODULE'}{"$mod"}{'LOCALPARAM'}};
        for (sort keys %compare_localparam) {
            $inside =~ s/$_/$compare_localparam{$_}/eig;
        } 
        replace_param($inside,$mod); 
    };
}