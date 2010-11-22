package Test::WebService::FitBit::weight;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub weight :Test(2) {
  my $test = shift;

  is( $test->{fb}->weight , '195.6' , 'weight' );
  is( $test->{fb}->weight('2010-10-20') , '195.6' , 'weight with date');
}
1;
