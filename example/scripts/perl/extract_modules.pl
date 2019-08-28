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

my $input_file = $ARGV[0];
my %json_data; 
my $nl;
# $json_data{"FILE_NAME"} = $input_file;
my $opt = new Verilog::Getopt;
$opt->parameter( "+incdir+verilog",
                 "-y","verilog",
                 );


my @dirs = (".");
my %seen;
while (my $pwd = shift @dirs) {
        opendir(DIR,"$pwd") or die "Cannot open $pwd\n";
        my @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
                next if $file =~ /^\.\.?$/;
                my $path = "$pwd/$file";
                if (-d $path) {
                        next if $seen{$path};
                        $seen{$path} = 1;
                        push @dirs, $path;
                }
                next if ($path !~ /\.v$/i);
                # my %json_data;
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
                # print "$myHashEncoded\n";
                # my $name_file = substr($path, 0, 4);
                my $name_file = substr(basename($path), 0, -2);
                print "$name_file\n";
                # open my $fh, ">", "$name_file.json";
                my $existingdir = "$pwd/.json";
                mkdir $existingdir unless -d $existingdir; # Check if dir exists. If not create it.
                open my $fh, ">", "$existingdir/$name_file.json" or die "Can't open '$existingdir/$name_file.json'\n";
                print $fh $myHashEncoded;
                close $fh;
        }
}
 
# Prepare netlist
# foreach my $file ($input_file) {
#     print $file;
#     $nl->read_file(filename=>$file);
# }
# # Read in any sub-modules
# $nl->link();
# # $nl->lint();  # Optional, see docs; probably not wanted
# $nl->exit_if_error();


 
# foreach my $mod ($nl->top_modules_sorted) {
#     show_hier($mod, "  ", "", "");
# }

# my $myHashEncoded = JSON->new->pretty->encode(\%json_data);
# # print "$myHashEncoded\n";
# my $name_file = substr($input_file, 0, 4);
# # open my $fh, ">", "$name_file.json";
# my $existingdir = './.json';
# mkdir $existingdir unless -d $existingdir; # Check if dir exists. If not create it.
# open my $fh, ">", "$existingdir/$name_file.json" or die "Can't open '$existingdir/$name_file.json'\n";
# print $fh $myHashEncoded;
# close $fh;
 
sub show_hier {
    my $mod = shift;
    my $indent = shift;
    my $hier = shift;
    my $cellname = shift;
    # printf($indent."%s\n", $mod->name);
    if (!$cellname) {
        $json_data{'TOP_MODULE'} = $mod->name;
        # print Dumper \%json_data;
        } #top modules get the design name
    else {
        $hier .= ".$cellname";
        } #append the cellname
    # printf("%-45s %s\n", "Module ".$mod->name,$hier);
    foreach my $cont ($mod->nets){
        # printf("%s : %s - %s\n",$cont->name, $cont->decl_type, $cont->width);

        if($cont->decl_type eq "parameter"){
            # printf("%s : %s - %s\n",$cont->name, $cont->decl_type, $cont->value);
            $json_data{'MODULE'}{$mod->name}{'PARAMETER'}{$cont->name} = $cont->value;
        }
        if($cont->decl_type eq "localparam"){
            # printf("%s : %s - %s\n",$cont->name, $cont->decl_type, $cont->value);
            $json_data{'MODULE'}{$mod->name}{'LOCALPARAM'}{$cont->name} = $cont->value;
        }
    }
    my %ports;
    foreach my $sig ($mod->ports_sorted) {
        # printf("%s - ",$sig->name);
            $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'DIRECTION'} = $sig->direction."put";
            if($mod->find_net($sig->name)->data_type =~ /.[a-z]+/i){
                foreach my $params ($json_data{'MODULE'}{$mod->name}{'PARAMETER'}){
                    foreach my $param (keys %$params) {
                        # print "PARAMETER: $param\n";
                    }
                    # if (index($sig->data_type, $param) != -1) {
                    #     print "It contains parameter'$param'\n";
                    # }
                }
                foreach my $params ($json_data{'MODULE'}{$mod->name}{'LOCALPARAM'}){
                    foreach my $param (keys %$params) {
                        # print "LOCALPARAM: $param\n";
                    }
                    # if (index($sig->data_type, $param) != -1) {
                    #     print "It contains parameter'$param'\n";
                    # }
                }
                $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = $sig->data_type;
                printf("%s - WIDE\n", $mod->find_net($sig->name)->data_type);
                # print "Width: ",$mod->find_net($sig->name)->data_type, "\n";
                if ( $mod->find_net($sig->name)->data_type =~ /\[(.*?)\:/ )
                {
                    my $inside = $1;
                    print "Extracted A: ", $inside, " at ", $sig->name,"\n";
                    try {
                        calc $inside;
                    } 
                    catch {
                        warn "Requires Param: $_";
                    }
                    finally {
                        $inside =~ s/(\d+)/replace_param($mod,$1)/eig;
                        print "Changed to: ", $inside, "\n";
                        foreach my $params ($json_data{'MODULE'}{$mod->name}{'PARAMETER'}){
                            foreach my $param (keys %$params) {
                                print "PARAM: ",$param, "\n";
                                if (index($inside, $param) != -1) {
                                    print "$inside contains $param\n";
                                } 
                                # print "PARAMETER: $param\n";
                            }
                            # if (index($sig->data_type, $param) != -1) {
                            #     print "It contains parameter'$param'\n";
                            # }
                        };
                    }
                }
                if ( $mod->find_net($sig->name)->data_type =~ /\:(.*?)\]/ )
                {
                    my $inside = $1;
                    print "Extracted B: ", $inside, " at ", $sig->name,"\n";
                    my $result = calc $inside;
                    print "Result : ", $result, "\n";
                }                   
                # TODO: Add check/replace for parameters in bus widths  
            }
            # if($mod->find_net($sig->name)->data_type =~ /.[a-z]+/i){
            #     foreach my $param (keys %{$json_data{'MODULE'}->{$mod->name}}){
            #         print "This is '$param{$_}'\n";
            #         # if (index($sig->data_type, $param) != -1) {
            #         #     print "It contains parameter '$param'\n";
            #         # }
            #     }
            #     $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = $sig->data_type;
            #     printf("%s - WIDE\n", $mod->find_net($sig->name)->data_type);
            # }
            else{
                if (defined $mod->find_net($sig->name)->width)
                {
                    $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = $mod->find_net($sig->name)->width;
                    # print "Width: ",$mod->find_net($sig->name)->data_type, "\n";
                    if ( $mod->find_net($sig->name)->data_type =~ /\[(.*?)\:/ )
                    {
                        my $inside = $1;
                        print "Extracted Net A: ", $inside, " at ", $sig->name,"\n";
                        try {
                            calc $inside;
                        } 
                        catch {
                            warn "Requires Param: $_";
                        }
                        finally {
                            if (@_) {
                                print "The try block died with: @_\n";
                            } else {
                                print "The try block ran without error.\n";
                            }
                            print "POP\n";
                            foreach my $params ($json_data{'MODULE'}{$mod->name}{'PARAMETER'}){
                                foreach my $param (keys %$params) {
                                    print $param, "\n";
                                    if (index($inside, $param) != -1) {
                                        print "$inside contains $param\n";
                                    } 
                                    # print "PARAMETER: $param\n";
                                }
                                # if (index($sig->data_type, $param) != -1) {
                                #     print "It contains parameter'$param'\n";
                                # }
                            };
                        }
                    }
                    if ( $mod->find_net($sig->name)->data_type =~ /\:(.*?)\]/ )
                    {
                        my $inside = $1;
                        print "Extracted Net B: ", $inside, " at ", $sig->name,"\n";
                        my $result = calc $inside;
                        print "Result : ", $result, "\n";
                    }                   
                }
                else
                {
                    $json_data{'MODULE'}{$mod->name}{'PORT'}{$sig->name}{'WIDTH'} = 1;
                }

                # printf("%s - WIDE\n", $mod->find_net($sig->name)->data_type);

                # printf("NUM\n");
            }            
    }
    foreach my $cell ($mod->cells_sorted) {
        # printf($indent. "    Cell %s\n", $cell->name);
        foreach my $pin ($cell->pins_sorted) {
            # printf($indent."     .%s(%s)\n", $pin->name, $pin->netname);
        }
        show_hier($cell->submod, $indent."   ", $hier, $cell->name) if $cell->submod;
    }
    # print Dumper \%json_data;
}

sub replace_param {
   # Get the subroutine's argument.
    my $mod = shift;
    my $arg = shift;
    
    # Hash of stuff we want to replace.
    my %replace = (
        "13" => "thirteen",
        "4" => "four",
    );
    my %compare = %{$json_data{'MODULE'}{$mod->name}{'PARAMETER'}};
    # for (sort keys %{ $json_data{'MODULE'}{$mod->name}{'PARAMETER'} }) {
    #     print "$_ A => ${ $json_data{'MODULE'}{$mod->name}{'PARAMETER'} }{$_}\n";
    # } 
    # for (sort keys %replace) {
    #     print "$_ B => $replace{$_}\n";
    # } 
    for (sort keys %compare) {
        print "$_ C => $compare{$_}\n";
    } 
    # print "REPLACED: ", $json_data{'MODULE'}{$mod->name}{'PARAMETER'}, "\n";

    # See if there's a replacement
    # for the given text.
    my $text = $compare{$arg};
    
    if(defined($text)) 
    {
        # Got a replacement; return it.
        print "REPLACED: ", $text, "\n";
        return $text;
    }
    
    # No replacement; return original text.
    return $arg;

}