package WebService::FitBit;
BEGIN {
  $WebService::FitBit::VERSION = '0.1_2';
}
BEGIN {
  $WebService::FitBit::AUTHORITY = 'cpan:GENEHACK';
}
# ABSTRACT: OO Perl API used to fetch fitness data from fitbit.com


use Moose;

use strictures 1;
use strict;
use 5.010;

use Carp;
use HTTP::Cookies;
use LWP::UserAgent;
use POSIX;
use Try::Tiny;
use XML::Simple;
use YAML            qw/ LoadFile /;

has 'base_url' => (
  is      => 'ro' ,
  isa     => 'Str' ,
  default => 'http://www.fitbit.com/graph/getGraphData' ,
);

has 'sid' => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has 'uid' => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has 'user_id' => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has '_browser' => (
  is       => 'ro' ,
  isa      => 'LWP::UserAgent' ,
  init_arg => '_set_browser',
  default  => sub { LWP::UserAgent->new( agent => "FitBit Perl API/2.0" ); } ,
  handles  => [ 'get' , 'cookie_jar' ] ,
);


sub BUILDARGS {
  my( $class , $args ) = @_;

  my $config_file = $args->{config} // "$ENV{HOME}/.fitbit";

  my $config = {};

  if ( -e $config_file ) {
    try { $config = LoadFile( $config_file ); }
    catch {
      warn "error parsing config file: $_\n";
      warn "CONFIG FILE IGNORED!\n";
    };
  }

  %$args = ( %$config , %$args );
  return $args;
}

sub BUILD {
  my( $self , $args ) = @_;

  my $cookie_jar = HTTP::Cookies->new;
  foreach( qw/ sid uid /) {
    $cookie_jar->set_cookie(
      1 , $_ , $self->$_ , '/' , 'www.fitbit.com' ,
      80 , 0 , 0 , 3600 , 0
    );
  }
  $self->cookie_jar( $cookie_jar );
}


sub active_score {
  my( $self , $date ) = @_;

  my $args = { type => 'activeScore' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return $data->[0]{value}{content};
}


sub activities_breakdown {
  my( $self , $date ) = @_;

  # ask for raw so we can get the data out of a different
  # part of the returned data structure...
  my $args = { type => 'activitiesBreakdown' , raw => 1 };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  $data = $data->{data}{pie}{slice};
  return {
    sedentary => $data->[0]{content} ,
    lightly   => $data->[1]{content} ,
    fairly    => $data->[2]{content} ,
    very      => $data->[3]{content} ,
  };
}


sub calories_burned {
  my( $self , $date ) = @_;
  return $self->calories_in_out($date)->{burned};
}


sub calories_consumed {
  my( $self , $date ) = @_;
  return $self->calories_in_out($date)->{consumed};
}


sub calories_in_out {
  my( $self , $date ) = @_;

  my $args = { type => 'caloriesInOut' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return {
    burned   => $data->[0]{value}{content} ,
    consumed => $data->[1]{value}{content} ,
  };

}


sub distance_from_steps {
  my( $self , $date ) = @_;

  my $args = { type => 'distanceFromSteps' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return $data->[0]{value}{content};
}


sub intraday_active_score {
  my( $self , $date ) = @_;

  my $args = { type => 'intradayActiveScore' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return _convert_intraday_log( $data );
}


sub intraday_calories_burned {
  my( $self , $date ) = @_;

  my $args = { type => 'intradayCaloriesBurned' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args);

  return _convert_intraday_log( $data );
}


sub intraday_sleep {
  die "NOT YET IMPLEMENTED";

  my( $self , $date ) = @_;

  my $args = { type => 'intradaySleep' , raw => 1  };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );
}


sub intraday_steps {
  my( $self , $date ) = @_;

  my $args = { type => 'intradaySteps' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return _convert_intraday_log( $data );
}


sub minutes_active {
  my( $self , $date ) = @_;

  my $args = { type => 'minutesActive' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return {
    lightly => $data->[0]{value}{content},
    fairly  => $data->[1]{value}{content},
    very    => $data->[2]{value}{content},
  };
}


sub steps_taken {
  my( $self , $date ) = @_;

  my $args = { type => 'stepsTaken' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return $data->[0]{value}{content};
}


sub time_asleep {
  my( $self , $date ) = @_;

  my $args = { type => 'timeAsleep' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return $data->[0]{value}{content} ,
}


sub times_woken_up {
  my( $self , $date ) = @_;

  my $args = { type => 'timesWokenUp' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return $data->[0]{value}{content},
}


sub weight {
  my( $self , $date ) = @_;

  my $args = { type => 'weight' };
  $args->{date} = $date if $date;

  my $data = $self->_fetch_data( $args );

  return $data->[0]{value}[0]{content};
}

# INTERNAL METHODS

## _build_fitbit_url

# takes a hashref of arguments and uses them to construct a URL to fetch a
# given dataset from the fitbit servers.

# accetpable keys:
#   - type    -- type of data to fetch
#   - period  -- amount of data to fetch. defaults to 1 day
#   - version -- not completely clear what this param does. defaults to 'amchart'
#   - date    -- date of data to fetch. default to current day (via _get_date()) if not given.

# returns the URL to fetch.

sub _build_fitbit_url {
  my( $self , $args ) = @_;

  $args->{date} //= _get_date();

  $self->_check_date_format( $args->{date} );

  my %params = (
    userId  => $self->user_id,
    type    => $args->{type}    || 'stepsTaken' ,
    period  => $args->{period}  || '1d',
    version => $args->{version} || 'amchart',
    dateTo  => $args->{date} ,
  );

  my $query_string = join '&', map { "$_=$params{$_}" } keys %params;

  return $self->base_url . '?' . $query_string;
}

## _check_date_format

# verifies that a date is in the proper 'YYYY-MM-DD' format.

# FIXME: actually, all it currently does is check that there are digits in
# those slots -- '0000-99-99' is an acceptable date by this algorithm.

sub _check_date_format {
  my( $self , $date ) = @_;

  # Very basic regex to check date format
  if ( $date !~ /^(\d{4})-(\d{2})-(\d{2})$/ ) {
    confess "Invalid date format [$date].  Expected (YYYY-MM-DD)";
  }

  return 1;
}

## _convert_intraday_log

# munges data from the goofy fitbit format to the only-slightly-less-goofy
# list-of-hashrefs format this module uses.

sub _convert_intraday_log {
  my( $data ) = @_;

  my @list = @{ $data->[0]{value} };
  pop @list; # get rid of the empty last element...

  my @return;

  foreach( @list ) {
    ### FIXME interval size should be set via param
    my $time      = $_->{xid} * 5;
    my $hours     = int( $time / 60 );
    my $minutes   = $time % 60;
    my $timestamp = sprintf "%02d:%02d" , $hours , $minutes;

    push @return , { $timestamp => $_->{content} }
  }

  return @return;
}

## _fetch_data

# takes a hashref of arguments and uses that info to fetch and return a
# particular dataset from fitbit.com.

# see _build_fitbit_url() for info on most of the arguments. The only other
# params of interest are:
#   - raw_xml -- if true, return the raw unparsed XML
#   - raw     -- if true, return the whole parsed XML structure

# by default, only the {data}->{chart}->{graphs}->{graph} portion of the XML
# structure is returned. That generally has all the information of interest.


sub _fetch_data {
  my( $self , $args ) = @_;

  # TODO Add methods for sleep; need to solve day-boundary problem (see python
  # code)

  my $url = $self->_build_fitbit_url( $args );

  # Note that user agent also uses cookie jar created on initialization
  my $response = $self->get($url);
  unless( $response->is_success ) {
    confess "Couldn't get graph data; reason = HTTP status ($response->{_rc})!";
  }
  my $xml = $response->content;
  # Strip leading whitespace for proper parsing
  $xml =~ s/^\s+//gm;

  return $xml if $args->{raw_xml};

  my $graph_data;
  try {
    $graph_data = XMLin( $xml, KeyAttr => [] , ForceArray => [ 'graph' ] );
  }
    catch { confess "$$: XMLin() died: $_\n" };

  return $graph_data if $args->{raw};

  return $graph_data->{data}{chart}{graphs}{graph};
}

## _get_date

# return today's date in YYYY-MM-DD

sub _get_date { return strftime( "%F", localtime ) }


1;

__END__
=pod

=head1 NAME

WebService::FitBit - OO Perl API used to fetch fitness data from fitbit.com

=head1 VERSION

version 0.1_2

=head1 SYNOPSIS

    use WebService::FitBit;

    # pulls default config from ~/.fitbit -- init that first, with
    # 'initialize_fitbit_config_file' command
    my $fb = WebService::FitBit->new();

    # No date defaults to today
    my @log = $fb->intraday_calories_burned();
    foreach (@log) {
        printf "time = %s -> calories = %s\n" , %$_;
    }

    printf "calories burned = %s\n" , $fb->calories_burned('2010-05-03');
    printf "active score    = %s\n" , $fb->active_score('2010-05-03');
    printf "steps           = %s\n" , $fb->steps_taken('2010-05-03');

=head1 DESCRIPTION

C<WebService::FitBit> provides an OO API for fetching fitness data from
fitbit.com.  Currently there is no official published
API. C<WebService::FitBit> works by accssing the XML feeds that drive the
Flash/JavaScript-based interface at fibit.com. That means that changes to the
location of format of those XML feeds could produce errors -- caveat user.

Intraday (5min and 1min intervals) logs are provided for:

 - calories burned
 - activity score
 - steps taken
 - sleep activity (every 1 min)

Historical (aggregate) info is provided for:

 - calories burned / consumed
 - activity score
 - steps taken
 - distance travels (miles)
 - sleep (total time in hours, and times awoken)

=head1 METHODS

=head2 new

    my $fb = WebService::FitBit->new();
    my $fb = WebService::FitBit->new({ config => 'alternate/file/location' });
    my $fb = WebService::FitBit->new({
      sid     => $sid ,
      uid     => $uid ,
      user_id => $user_id ,
    });

Returns a WebService::FitBit object. Generally you'll want to use the default
form, which pulls required parameters out of $ENV{HOME}/.fitbit. There is a
helper command included in the dist -- C<initialize_fitbit_config_file> --
which will prompt for an account name and password and then use those to
retrieve the required values from L<http://fitbit.com>

If you prefer, you can specify an alternate config file location with the
'config' parameter, or specify the required 'sid', 'uid', and 'user_id' values
directly.

If 'sid', 'uid', or 'user_id' parameters are supplied, they will override any
parameters read from the config.

=head2 active_score

    $score = $fb->active_score();
    $score = $fb->active_score('2010-10-20');

Returns the active score for a given date. Defaults to current date if none
given.

=head2 activities_breakdown

    my $activities_breakdown_hash = $fb->activities_breakdown();
    my $activities_breakdown_hash = $fb->activities_breakdown('2010-10-20');

Returns a hashref summarizing what percentage of the given date was spent in
each of four activity level categories: 'sedentary', 'lightly', 'fairly', and
'very'. If no date is given, defaults to the current date.

NOTE: The four values in the hash will sum to (approximately) 100, not 1. That
is, if half of the date was in the 'sedentary' level, the 'sedentary' key in
the hashref would have a value of '50'.

=head2 calories_burned

    $calories_burned = $self->calories_burned();
    $calories_burned = $self->calories_burned('2010-10-20');

Returns the number of calories burned on the given date. Defaults to the
current date if none given.

=head2 calories_consumed

    $calories_consumed = $self->calories_consumed();
    $calories_consumed = $self->calories_consumed('2010-10-20');

Returns the number of calories consumed on the given date. Defaults to the
current date if none given.

=head2 calories_in_out

    $calories_in_out_hashref = $fb->calories_in_out();
    $calories_in_out_hashref = $fb->calories_in_out('2010-10-20');

Returns a hashref with information about calories burned and consumed on the
given day. Calories burned are under the 'burned' key; calories consumed are
under the 'consumed' key.

=head2 distance_from_steps

    $distance_in_miles = $fb->distance_from_steps();
    $distance_in_miles = $fb->distance_from_steps('2010-10-20');

Returns the distance walked on the given date, in miles. Defaults to the
current date, if none given.

=head2 intraday_active_score

  @intraday_active_scores = $fb->intraday_active_score();
  @intraday_active_scores = $fb->intraday_active_score('2010-10-20');

Returns a list of hashrefs, each of the form 'time => value'. Times are
in five minute intervals, running from '00:00' to '23:55'. Values are the
activity score for that particular interval of the day.

Note that when requesting data for the current day, you still get the full
range of time values, even though some of them haven't occurred yet.

Takes a date argument; defaults to the current date if none is given.

=head2 intraday_calories_burned

  @intraday_calories_burned = $fb->intraday_calories_burned();
  @intraday_calories_burned = $fb->intraday_calories_burned('2010-10-20');

Returns a list of hashrefs, each of the form 'time => value'. Times are
in five minute intervals, running from '00:00' to '23:55'. Values are the
calories burned during that particular interval of the day.

Note that when requesting data for the current day, you still get the full
range of time values, even though some of them haven't occurred yet.

Takes a date argument; defaults to the current date if none is given.

=head2 intraday_sleep

NOT YET IMPLEMENTED. Patches welcomed.

=head2 intraday_steps

  @intraday_steps = $fb->intraday_steps();
  @intraday_steps = $fb->intraday_steps('2010-10-20');

Returns a list of hashrefs, each of the form C<( time => value )>. Times are
in five minute intervals, running from '00:00' to '23:55'. Values are the
number of steps taken during that particular interval of the day.

Note that when requesting data for the current day, you still get the full
range of time values, even though some of them haven't occurred yet.

Takes a date argument; defaults to the current date if none is given.

=head2 minutes_active

    $minutes_active_hashref = $fb->minutes_active();
    $minutes_active_hashref = $fb->minutes_active('2010-10-20');

Returns a hashref containing information about the time spent in the
'lightly', 'fairly', and 'very' activity levels for the given date. Defaults
to the current date if none given.

Values are expressed in fractional hours. I.e., if the 'very' key has a value
of '0.50', that indicates that 30 minutes were spent in that activity level.

=head2 steps_taken

    $steps_taken = $fb->steps_taken();
    $steps_taken = $fb->steps_taken('2010-10-20');

Returns the number of steps taken on the given date. Defaults to the current
date if none given.

=head2 time_asleep

    $hours_asleep = $fb->time_asleep();
    $hours_asleep = $fb->time_asleep('2010-10-20');

Returns the amount of time spent asleep on the given day. Defaults to the
current date if none given.

The value is expressed in fractional hours. I.e., a value of 7.5 indicates 7
hours and 30 minutes spent asleep.

TODO Currently unclear if this value is the sum of all sleeps on a given day
or just the value from the first or the value from the longest.

=head2 times_woken_up

    $times_woken_up = $fb->times_woken_up();
    $times_woken_up = $fb->times_woken_up('2010-10-20');

Returns the number of times woken up on the given day. Defaults to the current
date if none given.

TODO Currently unclear if this value is the sum of all sleeps on a given day
or just the value from the first or the value from the longest.

=head2 weight

    $weight = $fb->weight();
    $weight = $fb->weight('2010-10-20');

Returns the weight value for a given date, or the current date if none is given.

Note that the value returned for a day where no explict value was entered is
an interpolation done on the FitBit server side. Currently there is no way to
retrieve only the data that was explictly entered.

=head1 KNOWN_ISSUES

At this time, if you attempt to tally the intraday (5min) logs for the total
daily number, this number will NOT match the number from the equivalent API
call for the total number.  This is due to the way that FitBit feeds the
intraday values via XML to the flash-graph chart.  All numbers are whole
numbers, and this rounding issue causes the detailed log tally to be between
10-100 points higher.

For example:

    # Calling total = 2122
    print "Total calories burned = " . $fb->calories_burned . "\n";

    # Tallying total from log entries = 2157
    my $total = 0;
    for my $day ( $fb->intraday_calories_burned ) {
      my( $time , $value ) = %$day;
      $total += $value;
    }

=head1 CREDITS

Eric Blue did the initial version of this module, which solved most of the
annoying issues around deciphering the URL parameters and XML formats.

=head1 SEE ALSO

L<The FitBit site|http://fitbit.com>

L<Eric's original announcement|http://eric-blue.com/2010/05/11/fitbit-unofficial-perl-api-and-csv-download/>

=for Pod::Coverage BUILD

=head1 AUTHORS

=over 4

=item *

John SJ Anderson <genehack@genehack.org>

=item *

Eric Blue <ericblue76@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by John SJ Anderson.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

