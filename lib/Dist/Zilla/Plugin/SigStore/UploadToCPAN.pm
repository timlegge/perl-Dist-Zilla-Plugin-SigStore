use strict;
use warnings;
package Dist::Zilla::Plugin::SigStore::UploadToCPAN;
# VERSION
# ABSTRACT: upload a sigstore bundle to CPAN

use Moose;
extends 'Dist::Zilla::Plugin::UploadToCPAN';

use namespace::autoclean;

=head1 DESCRIPTION

Extends L<Dist::Zilla::Plugin::UploadToCPAN> to allow uploading an
arbitrary file (such as a sigstore bundle) rather than the release
archive itself.

=head1 ACKNOWLEDGEMENTS

Based on L<Dist::Zilla::Plugin::UploadToCPAN> by Ricardo SIGNES
and contributors.

=cut

=method upload_to_cpan($filename)

Internal function to upload to PAUSE

=cut

sub upload_to_cpan {
  my ($self, $archive) = @_;
  $self->before_release;
  $self->uploader->upload_file("$archive");
  return;
}

__PACKAGE__->meta->make_immutable;
1;
