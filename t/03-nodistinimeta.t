use strict;
use warnings;

use Test::More;
use Dist::Zilla::App::Tester;

# ABSTRACT: Test basic expansion

use Path::Tiny qw( path );

my $cwd     = Path::Tiny->cwd;
my $tempdir = Path::Tiny->tempdir;

my $result = test_dzil( "$tempdir", ['bakeini'] );
ok( ref $result, 'self test executed' );
isnt( $result->error,     undef, 'got errors' );
isnt( $result->exit_code, 0,     'exit != 0' );
like( $result->error, qr/dist\.ini\.meta\s+not\s+found/, 'No dist.ini.meta error' );

done_testing;

