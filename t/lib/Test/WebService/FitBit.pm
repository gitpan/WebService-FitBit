package Test::WebService::FitBit;
use base qw/ Test::WebService::FitBit::BASE /;

use strictures 1;

use Test::More;
use Test::Exception;

sub isa_fitbit :Test(1) {
  my $test = shift;

  isa_ok( $test->{fb} , 'WebService::FitBit' );
}

sub no_config_dies :Test(1) {
  dies_ok { WebService::FitBit->new({ config => 'does/not/exist' })}
    'new() without config throws exception';
}

1;
