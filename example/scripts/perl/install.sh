
ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
NONE="\e[0m"
PERL_VERSION=`perl -v`

if perl < /dev/null > /dev/null 2>&1  ; then
    echo -e "$SUCCESS\bPerl installed."
else
    echo -e "$ERROR\bPerl is not installed. $NONE"
    exit
fi

echo -e "Installing Perl Dependancies... $NONE"
sudo cpan JSON
PERL_MM_USE_DEFAULT=1 perl -MCPAN -e \
'install Verilog::Netlist; \
 install Verilog::Preproc; \
 install Verilog::CodeGen; \
 install JSON::XS'