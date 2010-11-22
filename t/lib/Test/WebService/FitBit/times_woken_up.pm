package Test::WebService::FitBit::times_woken_up;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub times_woken_up :Test(2) {
  my $test = shift;

  is( $test->{fb}->times_woken_up , '10.0' , 'times_woken_up' );
  is( $test->{fb}->times_woken_up('2010-10-20') , '10.0' , 'times_woken_up with date');
}
1;
