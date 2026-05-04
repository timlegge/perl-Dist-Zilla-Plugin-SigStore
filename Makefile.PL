use strict;
use warnings;



use ExtUtils::MakeMaker;

my %WriteMakefileArgs = (
  "ABSTRACT" => "Sign Release with SigStore",
  "AUTHOR" => "Timothy Legge <timlegge\@gmail.com>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0
  },
  "DISTNAME" => "Dist-Zilla-Plugin-SigStore-SignRelease",
  "LICENSE" => "perl",
  "NAME" => "Dist::Zilla::Plugin::SigStore::SignRelease",
  "PREREQ_PM" => {
    "Convert::ASN1" => 0,
    "Crypt::OpenSSL::X509" => 0,
    "Dist::Zilla::Role::AfterRelease" => 0,
    "Dist::Zilla::Role::BeforeRelease" => 0,
    "File::Slurper" => 0,
    "File::Which" => 0,
    "JSON::MaybeXS" => 0,
    "MIME::Base64" => 0,
    "Moose" => 0,
    "Try::Tiny" => 0,
    "namespace::autoclean" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.02",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Convert::ASN1" => 0,
  "Crypt::OpenSSL::X509" => 0,
  "Dist::Zilla::Role::AfterRelease" => 0,
  "Dist::Zilla::Role::BeforeRelease" => 0,
  "File::Slurper" => 0,
  "File::Which" => 0,
  "JSON::MaybeXS" => 0,
  "MIME::Base64" => 0,
  "Moose" => 0,
  "Try::Tiny" => 0,
  "namespace::autoclean" => 0,
  "strict" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
