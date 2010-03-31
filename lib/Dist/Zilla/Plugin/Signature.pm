package Dist::Zilla::Plugin::Signature;
use Moose;
with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::AfterBuild';


has sign => (is => 'ro', lazy_build => 1);

sub _build_sign {
  my $sign = 0;

  my $i = 0;

  # Not the best way to determine if an archive is being built
  # but there is not hook for BeforeArchive

  while (my ($package, $filename, $line, $subroutine) = caller($i++)) {
    if ($subroutine eq 'Dist::Zilla::build_archive') {
      $sign = 1;
      last;
    }
  }
  return $sign;
}

sub after_build {
  my ($self, $arg) = @_;

  require Module::Signature;
  require File::chdir;

  if (exists $ENV{DZSIGN} ? $ENV{DZSIGN} : $self->sign) {
    local $File::chdir::CWD = $arg->{build_root};
    Module::Signature::sign(overwrite => 1) && die "Cannot sign";
  }
}


sub gather_files {
  my ($self, $arg) = @_;

  require Dist::Zilla::File::InMemory;

  my $file = Dist::Zilla::File::InMemory->new({
    name    => 'SIGNATURE',
    content => "",
  });

  $self->add_file($file);

  return;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::Signature - sign releases with Module::Signature


=head1 DESCRIPTION

This plugin will sign a distribution using Module::Signature.

This plugin should appear after any other AfterBuild plugin in your C<dist.ini> file
to ensre that no files are modified after it has been run

=head1 ATTRIBUTES

=over

=item sign

A boolean value that if true will cause the build directory to get signed every time it it built.
By default the directory is only signed when an archive is to be built from it. If this attibute
is set false, then the directory will not be signed.

This attribute can be overridden by an environment variable C<DZSIGN>

=back

=head1 AUTHOR

  Graham Barr <gbarr@pobox.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Graham Barr.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


