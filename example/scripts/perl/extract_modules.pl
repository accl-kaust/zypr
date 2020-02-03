use Verilog::Netlist;
use strict;
use warnings;
use 5.010;
use Data::Diver qw(DiveRef DiveVal);
use Scalar::Util qw(looks_like_number);
use Math::Calc::Parser 'calc';
binmode STDOUT, ":utf8";
use utf8;
use Try::Tiny;
# use Data::Dumper qw(Dumper);
use Data::Dumper;
# use JSON;
use JSON::XS;
# Setup options so files can be found
use Verilog::Getopt;
use File::Find;
use File::Basename;

my $working_dir = $ARGV[0];
my $json_data = {}; 
my $nl;
my $prev_cut = 0;
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
print "########################################################################################\n";
while (my $pwd = shift @dirs) {
        opendir(DIR,"$pwd") or die "Cannot open $pwd\n";
        my @files = readdir(DIR);
        closedir(DIR);
        print "Working DIR: $pwd\n";
        $nl = new Verilog::Netlist(options => $opt,link_read => 1, link_read_nonfatal => 1);
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
                # undef %json_data;
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
                # foreach my $module ($nl->files_sorted){
                #     print $module->name;
                #     $json_data{"TOP_FILE"} = $module->name;
                # }

                # Read in any sub-modules
                $nl->link();
                # $nl->lint();  # Optional, see docs; probably not wanted
                                print "Extracting...\n";
                $nl->exit_if_error();

                # check if no cells, i.e. 
                foreach my $name ($nl->modules_sorted_level){
                    print $name->name;
                    print "\n";
                    print $name->cells;
                    print "\n";
                }

                my $count = 0;
                my %depth;
                # print $nl->modules_sorted_level;
                foreach my $number ($nl->top_modules_sorted)
                    {
                        # print "\n";                  
                        # my $fileref = $nl->read_file(filename=>$number->basename . '.v');
                        # print $fileref->dump;
                        # foreach my $file ($number->)
                        my @data;
                        walk_modules($number, 1, \@data, undef);      
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
            
            # $json_data{$mod->submod->name}= \%mod_hash;
            print "*********************\n";
            # print Dumper($json_data);
            # $json = JSON->new->utf8->max_depth(2048); 
            # my $json_nest = JSON::XS->new->utf8->pretty->max_depth(2048);
            # $json_nest->encode($json_data);
            # print $json_nest;

                    
                # foreach my $mod ($nl->top_modules_sorted) {
                #     $count += 1;
                #     print "INITIAL: $count\n";
                #     &show_hier($mod, "", "", "", \%depth);
                # }

                print "Encoding...\n";
                my $myHashEncoded = JSON::XS->new->pretty->encode($json_data);
                my $name_file = substr(basename($path), 0, -2);
                my $existingdir = "$pwd/.json";
                mkdir $existingdir unless -d $existingdir; # Check if dir exists. If not create it.
                open my $fh, ">", "$existingdir/$name_file.json" or die "Can't open '$existingdir/$name_file.json'\n";
                print $fh $myHashEncoded;
                close $fh;
}

sub walk_modules {
    my $module = shift;
    my $count = shift;
    my $array = shift;
    my $prev_mod = shift;
    my %mod_hash;

    if($module){
        if($module->is_top){
                $mod_hash{'MODULE'} = $module->name;
                push(@$array, 'CELL');
                push(@$array, 'top');
        }
        else{    
            # if(!defined($prev_mod)){

            # }
            # else{
            #     print '-' x $count;
            #     print ' MOD NAME: ';
            #     print $module->name;
            #     print "\n";
            # }
            $mod_hash{'MODULE'} = $module->name;
            if(!defined($prev_mod)){
                push(@$array, 'CELL');
                push(@$array, $module->name);
                print "\nNOT DEF ARRAY: ";
                print @$array;
                print "\n";
            }
        }

        foreach my $cont ($module->nets){
            if($cont->decl_type eq "parameter"){
                # print '-' x $count;
                # print "> PARAM: ";
                # print $cont->name; 
                $mod_hash{'PARAM'}{$cont->name} = $cont->value;
                # print "\n";
            }
            if($cont->decl_type eq "localparam"){
                # print '-' x $count;
                # print "> LOCAL PARAM: ";
                # print $cont->name;
                $mod_hash{'LOCALPARAM'}{$cont->name} = $cont->value;
                # print "\n";
            }
        } 

        foreach my $sig ($module->ports_sorted) {
            # $mod_hash{$module->name}{'LOCALPARAM'}{$cont->name} = $cont->value;
            $mod_hash{'PORT'}{$sig->name}{'DIRECTION'} = $sig->direction."put";
            if($module->find_net($sig->name)->data_type =~ /.[a-z]+/i){
                foreach my $params ($mod_hash{'PARAM'}){
                    foreach my $param (keys %$params) {
                    }
                }
                foreach my $params ($mod_hash{'LOCALPARAM'}){
                    foreach my $param (keys %$params) {
                    }
                }

                my $width = $module->find_net($sig->name)->data_type;
                my $result_a; 
                my $result_b;
                if ( $width =~ /\[(.*?)\:/ )
                {
                    $result_a = replace_param($1,$module->name,\%mod_hash);
                    # print "                                     RESULT A $result_a \n";
                }
                if ( $width =~ /\:(.*?)\]/ )
                {
                    $result_b = replace_param($1,$module->name,\%mod_hash);
                    # print "                                     RESULT B $result_b \n";
                }
                
                $mod_hash{'PORT'}{$sig->name}{'WIDTH'} = (($result_a+1)-$result_b);
            }
            else{
                if (defined $module->find_net($sig->name)->width)
                {
                    $mod_hash{'PORT'}{$sig->name}{'WIDTH'} = $module->find_net($sig->name)->width;
                }
                else
                {
                    $mod_hash{'PORT'}{$sig->name}{'WIDTH'} = 1;
                }
            }            
        }

        if(!$module->cells){
            $count = $count - 1;
            }
        else {
            foreach my $mod ($module->cells_sorted){
                # print '-' x $count;
                # print ' CELL-MOD NAME: ';
                # print $mod->name;
                # print "\n";
                
                $mod_hash{'CELL'}{$mod->name} = undef;
                    # print "\nARRAY: ";
                    # print @$array;
                    # print "\n";
            }
        }
        #     print "ARRAY: ";
        # print @$array;
        #     print "\n";
        # print Dumper(%mod_hash);
        DiveVal( $json_data, \( @$array ) ) = \%mod_hash;
        # if(!$module->cells){
        #     print "                                                         CUTTING: ";
        #     print $count;
        #     print "\n";
        #     # my @last_3_elements = splice @$array, ($count); 
        #     $count = $count - 1;
        #     print "END!\n";
        # }
        foreach my $mod ($module->cells_sorted){

            # print "                                                        Next Cell: ";
            # print $mod->name;
            # print "\n";
            # print "                                                        DEPTH: ";
            # print $count;
            # print "\n";
            # print "                                                        PREV: ";
            # print $prev_cut;
            # print "\n";
            if($prev_cut > $count){
                # print "                                                         SPLICE!\n";
                my @last_3_elements = splice @$array, (($count*2)); 
            }
            push(@$array, 'CELL');
            push(@$array, $mod->name);
            $prev_cut = $count;
            print $mod->submodname;
            print "\n";
            print $mod->pins;
            print "\n";
            if($mod->submod){
                walk_modules($mod->submod, $count + 1, \@$array, $module->name);
            }
            else {
                walk_modules($mod->submod, $count + 1, \@$array, $mod);
            }
        }
    }
    else {
        $mod_hash{'IPCORE'} = $prev_mod->submodname;
        foreach my $pin ($prev_mod->pins_sorted){
            print $pin->name;
            print " : ";
            my @pins     = $pin->pinselects;
            my $netname  = join(' ', map { $_->netname } @pins);
            print "$netname \n";
            $mod_hash{'PINS'}{$pin->name} = $netname;

        }
        $count = $count - 1;
        DiveVal( $json_data, \( @$array ) ) = \%mod_hash;

    }
  

}

# sub walk_hier {
#     step = shift;
#     json = shift


# }


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
 
# sub show_hier {
#     my $mod = shift;
#     my $indent = shift;
#     my $hier = shift;
#     my $cellname = shift;
#     my ($modname) = @_;
#     my $modthing = $mod->name;
#     # print $modname;
#     if($modname){
#         print "HASH\n";
#         foreach my $key (keys %$modname) {
#             print $modname->{$key};
#         }
#         print "END\n";
#     }

#     # print "{MODULE - $modname | CELL - {$modthing}\n";
#     if (!$cellname) {
#         $json_data{'TOP_MODULE'} = $mod->name;
#         } #top modules get the design name
#     else {
#         $hier .= ".$cellname";
#         } #append the cellname
#         # print "{HIER - $hier}\n";
#     # if (!$modname) {
#     #     print "MISSING!\n";
#     # }
#     # else {
#     #     $place{'HOLDER'} = $json_data{'MODULE'}{$mod->name}
#     # }

#     foreach my $cont ($mod->nets){
#         if($cont->decl_type eq "parameter"){
#             $json_data{'MODULE'}{$mod->name}{'PARAMETER'}{$cont->name} = $cont->value; 
#         }
#         if($cont->decl_type eq "localparam"){
#             $json_data{'MODULE'}{$mod->name}{'LOCALPARAM'}{$cont->name} = $cont->value;
#         }
#     }
#     my %ports;
#     foreach my $sig ($mod->ports_sorted) {
#             $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'DIRECTION'} = $sig->direction."put";
#             if($mod->find_net($sig->name)->data_type =~ /.[a-z]+/i){
#                 foreach my $params ($json_data{'MODULE'}{$mod->name}{'PARAMETER'}){
#                     foreach my $param (keys %$params) {
#                     }
#                 }
#                 foreach my $params ($json_data{'MODULE'}{$mod->name}{'LOCALPARAM'}){
#                     foreach my $param (keys %$params) {
#                     }
#                 }

#                 my $width = $mod->find_net($sig->name)->data_type;
#                 my $result_a; 
#                 my $result_b;
#                 if ( $width =~ /\[(.*?)\:/ )
#                 {
#                     $result_a = replace_param($1,$mod->name{$mod}
#                     $result_b = replace_param($1,$mod->name);
#                 }
#                 $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = (($result_a+1)-$result_b);
#             }
#             else{
#                 if (defined $mod->find_net($sig->name)->width)
#                 {
#                     $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = $mod->find_net($sig->name)->width;
#                 }
#                 else
#                 {
#                     $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = 1;
#                 }
#             }            
#     }
#     foreach my $cell ($mod->cells_sorted) {
#         foreach my $submod ($cell->submod->name) {
#             print $cell->submodname;
#             print "SUBMOD! $submod";
#             $modname->{$cell->name} = $cell->submodname;
#         }
#         foreach my $pin ($cell->pins_sorted) {
#         }
#         show_hier($cell->submod, $indent."   ", $hier, $cell->name,$modname) if $cell->submod;
#         # GENERATE LINKED LIST FOR MOD->NAME->MOD->NAME etc.
#         # Dynamically expand list to include modules
#     }
# }

sub replace_param {
    my $arg = shift;
    my $mod = shift;
    my ($hash) = @_;

    # print "ARG $arg";
    # print "\n";
    try {
        my $result = calc $arg;
        # print "CALULATED : $result !\n";
        return $result;
    } 
    catch {
        my $inside = $arg;
        my $compareparam = %$hash{'PARAM'};

        for(keys %$compareparam){
            $inside =~ s/$_/%$compareparam{$_}/eig;
            print("PARAM $_ is %compareparam{$_} : $inside\n");
        }

        my $comparelocalparam = %$hash{'LOCALPARAM'};

        for(keys %$comparelocalparam){
            $inside =~ s/$_/%$comparelocalparam{$_}/eig;
            print("LOCALPARAM $_ is %comparelocalparam{$_} : $inside\n");
        }

        replace_param($inside,$mod); 
    };
}

# sub replace_param {
#     my $arg = shift;
#     my $mod = shift;
#     try {
#         my $result = calc $arg;
#         return $result;
#     } 
#     catch {
#         my $inside = $arg;
#         my %compare_param = %{$json_data{'MODULE'}{"$mod"}{'PARAMETER'}};
#         for (sort keys %compare_param) {
#             $inside =~ s/$_/$compare_param{$_}/eig;
#         } 
#         my %compare_localparam = %{$json_data{'MODULE'}{"$mod"}{'LOCALPARAM'}};
#         for (sort keys %compare_localparam) {
#             $inside =~ s/$_/$compare_localparam{$_}/eig;
#         } 
#         replace_param($inside,$mod); 
#     };
# }