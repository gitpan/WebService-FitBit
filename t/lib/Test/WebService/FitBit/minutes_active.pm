package Test::WebService::FitBit::minutes_active;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub minutes_active :Test(2) {
  my $test = shift;

  my $test_data = {
    lightly   => '0.35' ,
    fairly    => '0.13' ,
    very      => '0.0' ,
  };

  is_deeply( $test->{fb}->minutes_active() ,
             $test_data , 'minutes_active' );
  is_deeply( $test->{fb}->minutes_active('2010-10-20') ,
             $test_data , 'minutes_active with date ' );
}

1;
