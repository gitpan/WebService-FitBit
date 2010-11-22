#! /opt/perl/bin/perl
# PODNAME: fetch_test_data

use warnings;
use strict;
use 5.010;
use autodie;

use FindBin;
use lib "$FindBin::RealBin/../../lib";

use WebService::FitBit;

my $fb = WebService::FitBit->new();

foreach my $type ( qw/
		       activeScore
		       caloriesInOut
		       distanceFromSteps
		       intradayActiveScore
		       intradayCaloriesBurned
                       intradayCaloriesEaten
		       intradaySleep
		       intradaySteps
		       minutesActive
		       timeAsleep
		       timesWokenUp
		       weight
  		       activitiesBreakdown
   		       stepsTaken
		     / ) {
  my $file = "$FindBin::Bin/$type.xml";

  if( -e $file ) {
    say "Skipping $type.xml; file exists.";
    next;
  }

  my $xml = $fb->fetch_data({
    type    => $type ,
    raw_xml => 1 ,
  });

  open( my $OUT , '>' , $file );
  print $OUT $xml;
  close( $OUT );

  say "Wrote $file";
}


