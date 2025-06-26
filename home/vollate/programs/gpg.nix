{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;

    settings = {
      # Basic settings
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list =
        "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
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
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    # Cache settings (seconds)
    defaultCacheTtl = 1800; # 30 minutes
    defaultCacheTtlSsh = 1800; # 30 minutes
    maxCacheTtl = 7200; # 2 hours
    maxCacheTtlSsh = 7200; # 2 hours

    # Pin entry program (new format)
    pinentry.package = pkgs.pinentry-curses;
  };

  # Shell 环境变量
  home.sessionVariables = {
    # 确保 GPG TTY 正确设置
    GPG_TTY = "$(tty)";
  };
}
