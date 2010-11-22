package Test::WebService::FitBit::active_score;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub active_score :Test(2) {
  my $test = shift;

  is( $test->{fb}->active_score , '52.0' , 'active score' );
  is( $test->{fb}->active_score('2010-10-20') , '52.0' , 'active score with date' );
}

1;
