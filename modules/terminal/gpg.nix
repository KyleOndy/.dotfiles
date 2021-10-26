{ lib, pkgs, config, ... }:
with lib;
let cfg = config.foundry.terminal.gpg;
in
{
  options.foundry.terminal.gpg = {
    enable = mkEnableOption "gpg";
    service = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # todo: this should be covered by the programs block
      gnupg # for email and git
      pinentry-curses # cli pin entry
    ];

    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = cfg.service;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
      pinentryFlavor = "curses";
      # todo: is this agent-config, or gpg config?
      # todo: move this into home-manager configuration
      # todo: a message on riseup says this config is deprecated, need to reevaluate
      extraConfig = ''
        #
        # This is an implementation of the Riseup OpenPGP Best Practices
        # https://help.riseup.net/en/security/message-security/openpgp/best-practices
        #


        #-----------------------------
        # default key
        #-----------------------------

        # The default key to sign with. If this option is not used, the default key is
        # the first key found in the secret keyring

        default-key 0xDB0E3C33491F91C9

        #-----------------------------
        # behavior
        #-----------------------------

        # Disable inclusion of the version string in ASCII armored output
        no-emit-version

        # Disable comment string in clear text signatures and ASCII armored messages
        no-comments

        # Display long key IDs
        keyid-format 0xlong

        # List all keys (or the specified ones) along with their fingerprints
        with-fingerprint

        # Display the calculated validity of user IDs during key listings
        list-options show-uid-validity
        verify-options show-uid-validity

        # Try to use the GnuPG-Agent. With this option, GnuPG first tries to connect to
        # the agent before it asks for a passphrase.
        use-agent


        #-----------------------------
        # keyserver
        #-----------------------------

        # This is the server that --recv-keys, --send-keys, and --search-keys will
        # communicate with to receive keys from, send keys to, and search for keys on
        keyserver hkps://hkps.pool.sks-keyservers.net

        # Set the proxy to use for HTTP and HKP keyservers - default to the standard
        # local Tor socks proxy
        # It is encouraged to use Tor for improved anonymity. Preferrably use either a
        # dedicated SOCKSPort for GnuPG and/or enable IsolateDestPort and
        # IsolateDestAddr
        #keyserver-options http-proxy=socks5-hostname://127.0.0.1:9050

        # When using --refresh-keys, if the key in question has a preferred keyserver
        # URL, then disable use of that preferred keyserver to refresh the key from
        keyserver-options no-honor-keyserver-url

        # When searching for a key with --search-keys, include keys that are marked on
        # the keyserver as revoked
        keyserver-options include-revoked

        keyserver-options auto-key-retrieve

        #-----------------------------
        # algorithm and ciphers
        #-----------------------------

        # list of personal digest preferences. When multiple digests are supported by
        # all recipients, choose the strongest one
        personal-cipher-preferences AES256 AES192 AES CAST5

        # list of personal digest preferences. When multiple ciphers are supported by
        # all recipients, choose the strongest one
        personal-digest-preferences SHA512 SHA384 SHA256 SHA224

        # message digest algorithm used when signing a key
        cert-digest-algo SHA512

        # This preference list is used for new keys and becomes the default for
        # "setpref" in the edit menu
        default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
      '';
    };
  };
}
