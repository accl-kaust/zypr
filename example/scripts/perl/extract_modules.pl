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
  print("RLT File: $rtlfiles\n");
}
# print(@things);
$opt->library(@rtlfiles);


my @dirs = (".");
my %seen;
while (my $pwd = shift @dirs) {
        opendir(DIR,"$pwd") or die "Cannot open $pwd\n";
        my @files = readdir(DIR);
        closedir(DIR);
        print "Working DIR: $pwd\n";
        $nl = new Verilog::Netlist(options => $opt,link_read => 1);
        my $path;
        foreach my $file (@rtlfiles) {
                next if $file =~ /^\.\.?$/;
                $path = "$file";
                if (-d $path) {
                        next if $seen{$path};
                        $seen{$path} = 1;
                        push @dirs, $path;
                }
                next if ($path !~ /\.v$/i);
                undef %json_data;
                my $mtime = (stat($path))[9];
                print "File found: $path | $pwd\n";
                $nl->read_file(filename=>$path);
        }
        # foreach my $file (@rtlfiles) {
        #         next if $file =~ /^\.\.?$/;
        #         my $path = "$file";
        #         if (-d $path) {
        #                 next if $seen{$path};
        #                 $seen{$path} = 1;
        #                 push @dirs, $path;
        #         }
        #         next if ($path !~ /\.v$/i);
        #         undef %json_data;
        #         my $mtime = (stat($path))[9];
        #         print "File found: $path | $pwd\n";

                $json_data{"FILE_NAME"} = basename($path);
                # Read in any sub-modules
                $nl->link();
                # $nl->lint();  # Optional, see docs; probably not wanted
                                print "Extracting...\n";
                $nl->exit_if_error();

                my $count = 0;
                my %depth;
                # print $nl->modules_sorted_level;
                foreach my $number ($nl->top_modules_sorted)
                    {
                        print $number->name;
                        print "\n";                  
                        # my $fileref = $nl->read_file(filename=>$number->basename . '.v');
                        # print $fileref->dump;
                        # foreach my $file ($number->)
                        my @data = undef;
                        walk_modules($number, 1, \@data, \%json_data);      
                        # foreach my $mod ($number->cells_sorted){
                        #     print " - ";
                        #     print $mod->submod->name;
                        #     print "\n";      
                        #     foreach my $mod ($mod->submod->cells_sorted){
                        #         print " -- ";
                        #         print $mod->submod->name;
                        #         print "\n"; 
                        #     }
                        # }
                    }

                    
                # foreach my $mod ($nl->top_modules_sorted) {
                #     $count += 1;
                #     print "INITIAL: $count\n";
                #     &show_hier($mod, "", "", "", \%depth);
                # }

                # print "Encoding...\n";
                # my $myHashEncoded = JSON->new->pretty->encode(\%json_data);
                # my $name_file = substr(basename($path), 0, -2);
                # my $existingdir = "$pwd/.json";
                # mkdir $existingdir unless -d $existingdir; # Check if dir exists. If not create it.
                # open my $fh, ">", "$existingdir/$name_file.json" or die "Can't open '$existingdir/$name_file.json'\n";
                # print $fh $myHashEncoded;
                # close $fh;
}

sub walk_modules {
    my $module = shift;
    my $count = shift;
    my @array = @{$_[0]};
    my ($json) = @_;

    # print @array;
    print '-' x $count;
    print ' MOD NAME: ';
    print $module->name;
    print "\n";

    foreach my $cont ($module->nets){
        if($cont->decl_type eq "parameter"){
            print '-' x $count;
            print "> PARAM: ";
            print $cont->name; 
            print "\n";
        }
        if($cont->decl_type eq "localparam"){
            print '-' x $count;
            print "> LOCAL PARAM: ";
            print $cont->name;
            print "\n";
        }
    }  
    foreach my $mod ($module->cells_sorted){
        # print ' ' x $count;
        # print '-> CELL NAME: ';
        # print $mod->submod->name;
        # print "\n";

        if(!$mod->submod->cells_sorted){
            # print "REC";
            print "\n";
            push(@array, $module->name);
            print "ARRAY: ";
            print "@array";
            print "\n";
            walk_modules($mod->submod, $count + 1, \@array);
        }
        else {
            to_nested_hash($json,\@array);
        }
    }
}

sub to_nested_hash {
    my $ref   = \shift;  
    my $h     = $$ref;
    my $value = pop;
    $ref      = \$$ref->{ $_ } foreach @_;
    $$ref     = $value;
    return $h;
}

# sub show_hier {
#     my $mod = shift;
#     my $indent = shift;
#     my $hier = shift;
#     my $cellname = shift;
#     if (!$cellname) {$hier = $mod->name;} #top modules get the design name
#     else {$hier .= ".$cellname";} #append the cellname

#     printf("%-45s %s\n", $indent."Module ".$mod->name,$hier);
#     foreach my $sig ($mod->ports_sorted) {
#         printf($indent."      %sput %s\n", $sig->direction, $sig->name);
#     }
#     foreach my $cell ($mod->cells_sorted) {
#         printf($indent. "    Cell %s\n", $cell->name);
#         foreach my $pin ($cell->pins_sorted) {
#             printf($indent."     .%s(%s)\n", $pin->name, $pin->netname);
#         }
#         show_hier($cell->submod, $indent."   ", $hier, $cell->name) if $cell->submod;
#     }
# }
 
sub show_hier {
    my $mod = shift;
    my $indent = shift;
    my $hier = shift;
    my $cellname = shift;
    my ($modname) = @_;
    my $modthing = $mod->name;
    # print $modname;
    if($modname){
        print "HASH\n";
        foreach my $key (keys %$modname) {
            print $modname->{$key};
        }
        print "END\n";
    }

    # print "{MODULE - $modname | CELL - {$modthing}\n";
    if (!$cellname) {
        $json_data{'TOP_MODULE'} = $mod->name;
        } #top modules get the design name
    else {
        $hier .= ".$cellname";
        } #append the cellname
        # print "{HIER - $hier}\n";
    # if (!$modname) {
    #     print "MISSING!\n";
    # }
    # else {
    #     $place{'HOLDER'} = $json_data{'MODULE'}{$mod->name}
    # }

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
        foreach my $submod ($cell->submod->name) {
            print $cell->submodname;
            print "SUBMOD! $submod";
            $modname->{$cell->name} = $cell->submodname;
        }
        foreach my $pin ($cell->pins_sorted) {
        }
        show_hier($cell->submod, $indent."   ", $hier, $cell->name,$modname) if $cell->submod;
        # GENERATE LINKED LIST FOR MOD->NAME->MOD->NAME etc.
        # Dynamically expand list to include modules
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