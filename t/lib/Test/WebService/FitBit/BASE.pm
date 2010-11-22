package Test::WebService::FitBit::BASE;
use strictures 1;
use base qw/ Test::Class /;

use Test::More;

use File::Slurp;
use FindBin;
use LWP::UserAgent;
use Test::MockObject::Extends;

use WebService::FitBit;

sub setup_fitbit_object :Test(setup) {
  my $test = shift;

  my $browser = LWP::UserAgent->new();
  my $mock_browser = Test::MockObject::Extends->new( $browser );

  $mock_browser->mock( 'get' , sub {
    my( $self , $url ) = @_;
    my( $type ) = $url =~ /type=([^&]+)&/ or die $url;

    my $file = "$FindBin::Bin/data/$type.xml";
    die "Can't find $file" unless -e $file;

    my $text = read_file( $file );
    my $response = HTTP::Response->new();
    my $mock_response = Test::MockObject::Extends->new( $response );
    $mock_response->mock( 'content' , sub { return $text } )
                  ->mock( 'is_success' , sub { return 1 } );
    return $mock_response;
  });

  $test->{fb} = WebService::FitBit->new({ _set_browser => $mock_browser });
}

1;
