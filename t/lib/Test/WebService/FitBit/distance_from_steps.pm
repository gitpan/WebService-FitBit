package Test::WebService::FitBit::distance_from_steps;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub distance_from_steps :Test(2) {
  my $test = shift;

  my $test_data = '0.11383521';

  is( $test->{fb}->distance_from_steps() ,
      $test_data , 'distance_from_steps' );
  is( $test->{fb}->distance_from_steps('2010-10-20') ,
      $test_data , 'distance_from_steps with date ' );

}

1;
