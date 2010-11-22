package Test::WebService::FitBit::intraday_sleep;
use base 'Test::WebService::FitBit::BASE';

use strictures 1;

use Test::More;

sub intraday_sleep :Test(2) {
  my $test = shift;

 SKIP: {
    skip 'not implemented yet' , 2;

    my $test_data = _test_data();

    my @log = $test->{fb}->intraday_sleep();
    is_deeply( \@log , $test_data , 'intraday_sleep' );

    my @log_by_date = $test->{fb}->intraday_sleep('2010-10-20');
    is_deeply( \@log_by_date , $test_data , 'intraday_sleep with date ' );
  }
}

sub _test_data {
  return [ ];
}

1;
