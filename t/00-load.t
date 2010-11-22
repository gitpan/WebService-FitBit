#! perl

use Test::More;

BEGIN {
  use_ok 'WebService::FitBit'
    or BAIL_OUT( "main module can't compile?!" )
}

diag "Testing WebService::FitBit version $WebService::FitBit::VERSION";

done_testing(1);
