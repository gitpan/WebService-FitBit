
use strict;
use warnings;

BEGIN { require 5.010; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'OO Perl API used to fetch fitness data from fitbit.com',
  'AUTHOR' => 'John SJ Anderson <genehack@genehack.org>, Eric Blue <ericblue76@gmail.com>',
  'BUILD_REQUIRES' => {
    'File::Find' => '0',
    'File::Slurp' => '0',
    'File::Temp' => '0',
    'FindBin' => '0',
    'Test::Class' => '0',
    'Test::Class::Load' => '0',
    'Test::Exception' => '0',
    'Test::MockObject::Extends' => '0',
    'Test::More' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'WebService-FitBit',
  'EXE_FILES' => [
    'bin/dump_fitbit_data_to_csv',
    'bin/initialize_fitbit_config_file'
  ],
  'LICENSE' => 'perl',
  'NAME' => 'WebService::FitBit',
  'PREREQ_PM' => {
    'Carp' => '0',
    'HTTP::Cookies' => '0',
    'HTTP::Request::Common' => '0',
    'LWP::UserAgent' => '0',
    'Moose' => '0',
    'POSIX' => '0',
    'Term::ReadKey' => '0',
    'Try::Tiny' => '0',
    'XML::Simple' => '0',
    'YAML' => '0',
    'autodie' => '0',
    'strictures' => '1'
  },
  'VERSION' => '0.1',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



