
ERROR='\e[0;31m'
SUCCESS="\e[0;32m"
NONE="\e[0m"
PERL_VERSION=`perl -v`

export PERL_MM_USE_DEFAULT=1

# if perl < /dev/null > /dev/null 2>&1  ; then
#     echo -e "$SUCCESS\bPerl installed."
# else
#     echo -e "$ERROR\bPerl is not installed. $NONE"
#     exit
# fi

echo -e "Installing Perl Dependancies... $NONE"
sudo cpan JSON
sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e \
'install Log::Log4perl; \
 install Verilog::Netlist; \
 install Verilog::Preproc; \
 install Verilog::CodeGen; \
 install Math::Calc::Parser; \
 install JSON::XS'