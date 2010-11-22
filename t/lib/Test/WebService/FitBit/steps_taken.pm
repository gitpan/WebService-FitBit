package Test::WebService::FitBit::steps_taken;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub steps_taken :Test(2) {
  my $test = shift;

  is( $test->{fb}->steps_taken , '252.0' , 'steps_taken' );
  is( $test->{fb}->steps_taken('2010-10-20') , '252.0' , 'steps_taken with date');
}
1;
