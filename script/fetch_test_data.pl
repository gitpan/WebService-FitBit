#! /opt/perl/bin/perl

use warnings;
use strict;
use 5.010;
use autodie;

use FindBin;
use lib "$FindBin::Bin/../lib";

use WWW::Fitbit::API;

my $fb = WWW::Fitbit::API->new();

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
  my $file = "$FindBin::Bin/../t/data/$type.xml";

  if( -e $file ) {
    say "Skipping $type.xml; file exists.";
    next;
  }

  my $xml = $fb->fetch_data({
    type    => $type ,
    raw_xml => 1 ,
  });

  open( OUT , '>' , $file );
  print OUT $xml;
  close( OUT );

  say "Wrote $file";
}


