use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Dist::Zilla::App::Command::bakeini;

our $VERSION = '0.001001';

# ABSTRACT: bake dist.ini to not need the bundles.

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY

use Dist::Zilla::App '-command';
## no critic (NamingConventions::ProhibitAmbiguousNames)
sub abstract { return 'bake dist.ini from dist.ini.meta' }






















































































sub opt_spec {
  return ( [ 'root=s' => 'the root of the dist; defaults to .' ], );
}

sub validate_args {
  my ( undef, $opt, undef ) = @_;
  require Path::Tiny;

  my $root = $opt->root;
  $root = Path::Tiny::path($root) if defined $root;
  $root = Path::Tiny::cwd()       if not defined $root;

  return if $root->child('dist.ini.meta')->is_file;
  require Carp;
  Carp::croak("dist.ini.meta not found in $root");
}

sub execute {
  my ( undef, $opt, undef ) = @_;
  require Path::Tiny;

  my $root = $opt->root;
  $root = Path::Tiny::path($root) if defined $root;
  $root = Path::Tiny::cwd()       if not defined $root;

  my $file = $root->child('dist.ini.meta');

  require Dist::Zilla::Util::ExpandINI;
  my $state = Dist::Zilla::Util::ExpandINI->new();
  $state->_load_file($file);
  $state->_expand();
  my $out = $root->child('dist.ini')->openw_utf8;
  my $return = print {$out} "; This file is generated from dist.ini.meta by dzil bakeini.\n",
    "; Edit that file or the bundles contained within for long-term changes.\n";
  if ( not $return ) {
    require Carp;
    Carp::croak("Error writing to dist.ini! $? $! $@");
  }
  $state->_store_handle($out);
  return;
}





















1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::App::Command::bakeini - bake dist.ini to not need the bundles.

=head1 VERSION

version 0.001001

=head1 SYNOPSIS

  cp dist.ini dist.ini.meta
  dzil bakeini

  less dist.ini # no more bundles :D

=head1 DESCRIPTION

=head2 The Quibbles

There's several long standing point of contention surrounding the use of bundles.

A few poignant ones that bother me are:

=over 4

=item * Bundles change over time and configuration parameters can change in validity

For example, I might add a requirement in a later incarnation of a bundle that a given parameter be specified. But that creates
a confusing backwards compatibility problem for people who merely want to check out and build the code.

=item * Some contributors tend not to like dealing with bundles due to bundle complexity

Bundles often declare far more dependencies than contributors B<need> to build one specific distribution, and the bundle
obscures the visibility of what plugins are being used.

This also manifests as a difficulty to work around problems produced by bundles such as bundles C<use>-ing broken modules,
which is not straight forward to iron out with the C<@Filter> bundle.

C<@Filter> is also complicated for end users who are not familiar with C<dzil> to use, and C<@Filter> also lacks abilities to
re-order plugins if that is necessary to avoid a bug.

Additionally, routing configuration to a single plugin within a bundle can be confusing with messy syntax, especially if the
bundle doesn't C<do> C<ConfigSlicer> or something like that.

And the effort of learning and using those tools is high if all you want to do is I<temporarily> change a build setting for the
point of local use or local testing.

=back

=head2 The Benefits and Method

So this command attempts to avoid these problems by separating the bundle from its configuration until configuration is wanted
updated.

This means C<Dist::Zilla> based distributions B<DON'T> have their build configuration radically changed simply because somebody
upgraded a bundle, and the configuration is I<MORE> local to the distribution instead of being more global.

This means bundle specific configuration demands B<ONLY> need to be satisfied during the baking process, but B<NOT> every
subsequent build, and are thus B<NOT> prone to causing a sea of unusable C<dist.ini>s if a bundle gets changed.

=head2 The Downsides

The biggest known downside of this approach at present is with much more advanced bundle usage.

Because the bundle itself is being taken out of the loop, that means C<dist.ini> will B<NOT> be able to automatically have new
plugins added to it in response to changes in the tree. C<dzil bakeini> will have to be run subsequently to take tree changes
into consideration and emit updated configuration.

And because the bundle itself is being taken out of the loop, that means C<ENV> based controls in bundles will be bound at the
time of calling C<dzil bakeini>, which means if you're like C<@ETHER> and have an "Airplane mode", then:

  AIRPLANE=1 dzil build

Won't work on a baked C<dist.ini>, and you will instead need:

  AIRPLANE=1 dzil bakeini && dzil build

Though, that could be beneficial too depending on how you use it.

  # Get on the plane
  AIRPLANE=1 dzil bakeini

  # dzil runs everything in airplane mode now
  dzil build

  # Get off the plane
  dzil bakeini

  # dzil runs normally
  dzil build

=head1 TIPS AND TRICKS

=head2 C<bakeini> dependent behaviour in a bundle

If you want to codify some unique behavior to how your bundle performs under C<dzil bakeini>, ( for instance, to change the C<prereqs> advertised as being C<develop.requires> )

Here, L<< C<::Util::CurrentCmd>|Dist::Zilla::Util::CurrentCmd >> comes in handy:

  use Dist::Zilla::Util::CurrentCmd qw(current_cmd);

  my @config;
  ...
  if ( 'bakeini' eq ( current_cmd() || '' ) ) {
      push @config, [ 'baked dist prereqs', 'Dist::Zilla::Plugin::Prereqs', { 'Foo::Bar' => 2  }];
  } else {
    ...
  }

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
