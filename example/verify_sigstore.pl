# This software is copyright (c) 2026 by Timothy Legge <timlegge@gmail.com>.
# 
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.

use strict;
use warnings;
use File::Slurper qw/read_binary/;
use Getopt::Long;
use JSON::MaybeXS;
use MIME::Base64  qw/decode_base64/;
use Crypt::OpenSSL::X509;
use Try::Tiny;
use Convert::ASN1;

my ($module, $bundle_name, $verify_identity);
GetOptions(
    'module=s' => \$module,
    'verify_identity=s' => \$verify_identity,
    'bundle=s' => \$bundle_name,
) or die "Usage: $0 --module <file> [--verify_identity 'user\@gmailcom'] [--bundle <file>]\n";

# Allow positional fallback: verify_sigstore.pl Module.tar.gz user\@gmailcom' [bundle.json]
$module      //= shift @ARGV
    or die "Usage: $0 --module <file> --verify_identity 'user\@gmailcom' [--bundle <file>]\n";
$verify_identity //= shift @ARGV
    or die "Usage: $0 --module <file> --verify_identity 'user\@gmailcom' [--bundle <file>]\n";;
$bundle_name //= shift @ARGV;

# Guess bundle name from module filename if not provided
$bundle_name //= "$module.sigstore.json";

die "Module file '$module' not found\n"      unless -f $module;
die "Bundle file '$bundle_name' not found\n" unless -f $bundle_name;

sub _load_bundle {
    my $bundle_name = shift; 

    my $bundle_json = read_binary($bundle_name);
    my $bundle_decoded = decode_json($bundle_json) or die;
    
    return $bundle_decoded;
}

sub _get_der_from_bundle {
    my $bundle = shift;

    my $cert;
    if (defined $bundle->{mediaType} && $bundle->{mediaType} eq 'application/vnd.dev.sigstore.bundle.v0.3+json')
    {
        $cert = $bundle->{verificationMaterial}->{certificate}->{rawBytes};
    } else {
        $cert = decode_base64($bundle->{cert});
        $cert =~ s/-----[^-]*-----//gm;
    }

    return decode_base64($cert);
}
sub _get_x509_from_der {
    my $der = shift;
    return Crypt::OpenSSL::X509->new_from_string(
        $der, Crypt::OpenSSL::X509::FORMAT_ASN1
    );
}

sub _decode_oid_value {
    my ($extensions, $oid) = @_;
    return "" unless $oid;
    
    my $hex_value;
    if (exists $extensions->{$oid}) {
        $hex_value = $extensions->{$oid}->value();
    } else {
        die "Unable to find oid value for $oid\n";
    }

    # Remove leading '#' and pack to binary
    $hex_value =~ s/^#//;
    my $binary = pack("H*", $hex_value);
    my $asn = Convert::ASN1->new;

    if ($oid eq '1.3.6.1.4.1.57264.1.1') {
        return $binary;
    }
    elsif ($oid eq '2.5.29.17') {
        $asn->prepare(q(
            GeneralNames ::= SEQUENCE OF GeneralName
            GeneralName ::= CHOICE {
                rfc822Name                      [1]     IA5String
            }
        )) or die "Unable to prepare ASN1 template";
        my $schema = $asn->find('GeneralNames')
            or die "Cannot find GeneralNames in schema";
        my $decoded = $schema->decode($binary);

        # Return the first email found in the sequence
        return $decoded->[0]->{rfc822Name};
    }

    return "Unknown OID Format";
}

my $bundle      = _load_bundle($bundle_name);
my $der         = _get_der_from_bundle ($bundle);
my $x509        = _get_x509_from_der($der);
my $extensions  = $x509->extensions_by_oid();
my $identity    = _decode_oid_value($extensions, '2.5.29.17');
my $issuer      = _decode_oid_value($extensions, '1.3.6.1.4.1.57264.1.1');

my $verified = try {
        `cosign verify-blob $module --bundle $bundle_name --certificate-identity $verify_identity --certificate-oidc-issuer $issuer 2>&1`;
    };
my $exit_code = $? >> 8;

if ($exit_code eq 0 && $verified =~ qr/OK/) {
    print "Verified $module signed by $identity via $issuer\n";
} else {
    print "Failed\n";
}
