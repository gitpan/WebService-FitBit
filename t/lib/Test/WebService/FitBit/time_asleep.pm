package Test::WebService::FitBit::time_asleep;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub time_asleep :Test(2) {
  my $test = shift;

  is( $test->{fb}->time_asleep , '5.4333334' , 'time_asleep' );
  is( $test->{fb}->time_asleep('2010-10-20') , '5.4333334' , 'time_asleep with date');
}
1;
