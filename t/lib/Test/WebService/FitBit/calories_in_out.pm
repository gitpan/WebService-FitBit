package Test::WebService::FitBit::calories_in_out;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub calories_in_out :Test(2) {
  my $test = shift;

  my $test_data = {
    burned   => '506.0' ,
    consumed => '0.0' ,
  };

  is_deeply( $test->{fb}->calories_in_out() ,
             $test_data , 'calories_in_out' );
  is_deeply( $test->{fb}->calories_in_out('2010-10-20') ,
             $test_data , 'calories_in_out with date ' );

}

sub burned :Test(2) {
  my $test = shift;

  is( $test->{fb}->calories_burned , '506.0' , 'calories_burned' );
  is( $test->{fb}->calories_burned('2010-10-20') ,
      '506.0' , 'calories_burned with date' );
}

sub consumed :Test(2) {
  my $test = shift;

  is( $test->{fb}->calories_consumed , '0.0' , 'calories_consumed' );
  is( $test->{fb}->calories_consumed('2010-10-20') ,
      '0.0' , 'calories_consumed with date' );
}

1;
