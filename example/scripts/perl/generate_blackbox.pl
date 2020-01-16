use Data::Dumper;
use Data::Diver qw(DiveRef DiveVal);

my $foo = "alphabet";
my $bar = "a:b:c:d:z";
my $hoh = {};
my %test = ('rabbit' => 123);

sub add_item
{
    my $href = shift;
    my $str  = shift;

    my @keys= ('test','tedgf','thing');
    # my $last= pop @keys;
    DiveVal( $href, \( @keys ) ) = \%test;


    return;
}

add_item($hoh, $foo);
# add_item($hoh, $bar);
print Dumper($hoh);