use Verilog::CodeGen;;
 
mkdir '../../rtl/.blackbox', 0755;
chdir '../../rtl/.blackbox';
 
# if the directory YourDesign exists, the second argument can be omitted 
# create YourModule.pl in YourDesign 
&create_template_file('YourModule'); 
 
# create a device library for testing in DeviceLibs/Objects/DeviceLibs
&make_module('YourModule');
 
# create the final device library in DeviceLibs (once YourModule code is clean)
&make_module('');

sub gen_YourModule {    
  my $objref=shift;
  my $par=$objref->{parname}||1;
  
  # Create Objects
  
  my $submodule=new('SubModule',parname1=>$par);
  
  # Instantiate
  
  my $pins="(A,Z)";
  my $modname=$objref->{modulename};
  my $code = "
  module $modname $pins;
  input A;
  output Z;
  ";
  $code.=$submodule->inst('suffix',P1=>'A');
  $code .="
  endmodule // $modname
  ";
  $objref->{pins}=$pins;
  return $code;
} # END of gen_YourModule