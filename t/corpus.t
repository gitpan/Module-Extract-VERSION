use strict;
use warnings;

use File::Spec;

use Test::More 'no_plan';

use_ok( 'Module::Extract::VERSION' );
can_ok( 'Module::Extract::VERSION', qw(parse_version_safely) );

use constant SIGIL      => 0;
use constant IDENTIFIER => 1;
use constant VALUE      => 2;
use constant LINE       => 3;

my %Corpus = (
	'Easy.pm'             => [ qw( $ VERSION                3.01    3 ) ],
	'RCS.pm'              => [ qw( $ VERSION                1.23    5 ) ],
	'Underscore.pm'       => [ qw( $ VERSION                0.10_01 3 ) ],
	'DifferentPackage.pm' => [ qw( $ DBI::PurePerl::VERSION 1.23    3 ) ],
	'NoVersion.pm'        => [ (undef) x 4 ],
	);
	
foreach my $file ( sort keys %Corpus )
	{
	my $path = File::Spec->catfile( 'corpus', $file );
	ok( -e $path, "Corpus file [ $path ] exists" );
	
	# scalar context
	{
	my $version = 
		eval{ Module::Extract::VERSION->parse_version_safely( $path ) };
	is( $version, $Corpus{$file}[VALUE], "Works for $file (scalar context)" );
	}
		
	# list context
	{
	my ( $sigil, $identifier, $value, $filename, $line ) = 
		eval{ Module::Extract::VERSION->parse_version_safely( $path ) };
	if( $@ ) 
		{
		diag( $@ );
		next;
		}
		
	is( $sigil,      $Corpus{$file}[SIGIL],      "Right sigil for $file" );
	is( $identifier, $Corpus{$file}[IDENTIFIER], "Right identifier for $file" );
	is( $value,      $Corpus{$file}[VALUE],      "Right value for $file" );
	is( $file,       $file,                      "Right filename for $file" );
	is( $line,       $Corpus{$file}[LINE],       "Right line for $file" );
	
	}
	
	}
