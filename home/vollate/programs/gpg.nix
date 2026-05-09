{
  config,
  lib,
  pkgs,
  ...
}:

let
  pinentryWrapper = pkgs.writeShellScriptBin "pinentry" ''
    if [ -n "''${SSH_CONNECTION:-}" ]; then
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    elif [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      exec ${pkgs.pinentry-qt}/bin/pinentry-qt "$@"
    else
      exec ${pkgs.pinentry-curses}/bin/pinentry-curses "$@"
    fi
  '';
in
{
  programs.gpg = {
    enable = true;

    settings = {
      # Basic settings
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";

      # Display settings
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;

      # Behavior settings
      use-agent = true;
      require-cross-certification = true;
      no-symkey-cache = true;
      throw-keyids = true;
    };
  };

  # GPG Agent service
  services.gpg-agent = {
    enable = false;
    enableSshSupport = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    defaultCacheTtl = 1800; # 30 minutes
    defaultCacheTtlSsh = 1800; # 30 minutes
    maxCacheTtl = 7200; # 2 hours
    maxCacheTtlSsh = 7200; # 2 hours

    pinentry.package = pinentryWrapper;
  };

}
