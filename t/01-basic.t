use strict;
use warnings;

use Test::More;
use Dist::Zilla::App::Tester;
use Test::Differences;

# ABSTRACT: Test basic expansion

use Path::Tiny qw( path );

my $cwd     = Path::Tiny->cwd;
my $tempdir = Path::Tiny->tempdir;

$tempdir->child('dist.ini.meta')->spew_raw(<<'EOF');
name = Example-Dist
author = A.U.Thor <author@example.org>
license = Perl_5
copyright_holder = Kent Fredric <kentfredric@gmail.com>

[@Basic]
EOF

my $result = test_dzil( "$tempdir", ['bakeini'] );
ok( ref $result, 'self test executed' );
is( $result->error,     undef, 'no errors' );
is( $result->exit_code, 0,     'exit == 0' );

my $rtemp = path( $result->{tempdir} )->child('source');

ok( -e $rtemp->child('dist.ini'), 'dist.ini generated' );
my (@lines) = $rtemp->child('dist.ini')->lines_raw( { chomp => 1 } );

my $expected = [
  '; This file is generated from dist.ini.meta by dzil bakeini.',
  '; Edit that file or the bundles contained within for long-term changes.',
  'name = Example-Dist',
  'author = A.U.Thor <author@example.org>',
  'license = Perl_5',
  'copyright_holder = Kent Fredric <kentfredric@gmail.com>',
  '',
  '[GatherDir / Dist::Zilla::PluginBundle::Basic/GatherDir]',
  '',
  '[PruneCruft / Dist::Zilla::PluginBundle::Basic/PruneCruft]',
  '',
  '[ManifestSkip / Dist::Zilla::PluginBundle::Basic/ManifestSkip]',
  '',
  '[MetaYAML / Dist::Zilla::PluginBundle::Basic/MetaYAML]',
  '',
  '[License / Dist::Zilla::PluginBundle::Basic/License]',
  '',
  '[Readme / Dist::Zilla::PluginBundle::Basic/Readme]',
  '',
  '[ExtraTests / Dist::Zilla::PluginBundle::Basic/ExtraTests]',
  '',
  '[ExecDir / Dist::Zilla::PluginBundle::Basic/ExecDir]',
  '',
  '[ShareDir / Dist::Zilla::PluginBundle::Basic/ShareDir]',
  '',
  '[MakeMaker / Dist::Zilla::PluginBundle::Basic/MakeMaker]',
  '',
  '[Manifest / Dist::Zilla::PluginBundle::Basic/Manifest]',
  '',
  '[TestRelease / Dist::Zilla::PluginBundle::Basic/TestRelease]',
  '',
  '[ConfirmRelease / Dist::Zilla::PluginBundle::Basic/ConfirmRelease]',
  '',
  '[UploadToCPAN / Dist::Zilla::PluginBundle::Basic/UploadToCPAN]'
];

eq_or_diff \@lines, $expected, 'Generated dist.ini is expanded';

done_testing;

