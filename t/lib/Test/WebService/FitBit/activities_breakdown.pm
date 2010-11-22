package Test::WebService::FitBit::activities_breakdown;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub activities_breakdown :Test(2) {
  my $test = shift;

  my $test_data = {
    sedentary => '62.75' ,
    lightly   => '26.249998' ,
    fairly    => '10.0' ,
    very      => '1.0' ,
  };

  is_deeply( $test->{fb}->activities_breakdown() ,
             $test_data , 'activities_breakdown' );
  is_deeply( $test->{fb}->activities_breakdown('2010-10-20') ,
             $test_data , 'activities_breakdown with date ' );
}

1;
