# NAME

Dist::Zilla::Plugin::SigStore::SignRelease - Sign Release with SigStore

# VERSION

version 0.02

# SYNOPSIS

In your `dist.ini`:

```
[SigStore::SignRelease]
upload_to_cpan     = 1             ; Upload the sigstore bundle to CPAN (optional)
sigstore_extension = sigstore.json ; Extension of the sigstore bundle (optional)
answer_yes         = 1             ; Answer yes to any cosign messages (Default = 0)
```

**Note**: that _upload\_to\_cpan_ defaults to true (1).

# DESCRIPTION

This plugin will sign a CPAN Release with SigStore

# Required Plugins

This plugin requires that your Dist::Zilla configuration do the following:

```
1. Create a release
```

There are numerous combinations of Dist::Zilla plugins that can perform those
functions.

# SIGSTORE INFORMATION

The current version requires the installation of the **cosign** application. That
application can be accessed via the SigStore web site:

[https://docs.sigstore.dev/cosign/system\_config/installation/](https://docs.sigstore.dev/cosign/system_config/installation/)

# CPAN SUPPORT

As of version 0.01 there is no support in PAUSE or any CPAN client for sigstore
signature verification.

# MANUAL SIGNATURE VERIFICATION

```
cosign verify-blob Dist-Zilla-Plugin-SigStore-SignRelease-0.01.tar.gz \
    --bundle Dist-Zilla-Plugin-SigStore-SignRelease-0.01.tar.gz.sigstore.json \
    --certificate-identity timlegge@gmail.com \
    --certificate-oidc-issuer https://accounts.google.com
```

The GitHub repository also includes a script in the examples directory that
can be used to manually verify signatures.

[https://github.com/timlegge/perl-Dist-Zilla-Plugin-SigStore/blob/main/example/verify\_sigstore.pl](https://github.com/timlegge/perl-Dist-Zilla-Plugin-SigStore/blob/main/example/verify_sigstore.pl)

# ATTRIBUTES

- upload\_to\_cpan
    true (1) or false (0) - Default = 1
- sigstore\_extension
    Defaults to 'sigstore.json' (Optional)
    The extension is appended to the end of the distribution's filename.

    ```
    example: Distribution-0.99.tar.gz.sigstore.json
    ```

- answer\_yes
    true (1) or false (0) - Default = 0
    This answers yes to any cosign messages that require an answer.

# METHODS

- after\_release

    The main processing function that is called automatically after the release is complete.

# AUTHOR

Timothy Legge <timlegge@gmail.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2026 by Timothy Legge <timlegge@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
