package Dist::Zilla::Plugin::Signature;
use Moose;
with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::BeforeArchive';


sub before_archive {
  my ($self, $arg) = @_;

  require Module::Signature;
  require File::chdir;

  local $File::chdir::CWD = $arg->{build_root};
  Module::Signature::sign(overwrite => 1) && die "Cannot sign";
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

This plugin will sign a distribution using Module::Signature

=head1 AUTHOR

  Graham Barr <gbarr@pobox.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Graham Barr.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


