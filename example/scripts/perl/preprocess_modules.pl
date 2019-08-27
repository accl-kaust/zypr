use Data::Find qw( diter );
 
my $data = {
  ar => [1, 2, 3],
  ha => {one => 1, two => 2, three => 3}
};
 
my $iter = diter $data, 3;
while ( defined ( my $path = $iter->() ) ) {
  print "$path\n";
}