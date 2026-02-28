{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Read proxy from environment variables if set
  httpProxy = builtins.getEnv "http_proxy";
  httpsProxy = builtins.getEnv "https_proxy";
  hasProxy = httpProxy != "" || httpsProxy != "";
in
{
  nix = {
    # Enable flakes and new command
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Binary cache mirrors for China
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@wheel"
      ];
      builders-use-substitutes = true;
      auto-optimise-store = true;

      # Parallel downloads and builds
      max-jobs = "auto"; # Auto-detect CPU cores for parallel builds
      cores = 0; # Use all available cores per build job
      max-substitution-jobs = 16; # Parallel download of pre-built packages
      http-connections = 128; # HTTP connections per download (speeds up fetching)
      connect-timeout = 10;
    }
    // lib.optionalAttrs hasProxy {
      # Use proxy if environment variables are set
      http-proxy = if httpProxy != "" then httpProxy else httpsProxy;
      https-proxy = if httpsProxy != "" then httpsProxy else httpProxy;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide proxy configuration (if environment variables are set)
  networking.proxy = lib.mkIf hasProxy {
    default = if httpProxy != "" then httpProxy else httpsProxy;
    noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Set proxy environment variables for all users
  environment.variables = lib.mkIf hasProxy (
    {
      no_proxy = "127.0.0.1,localhost,internal.domain";
      NO_PROXY = "127.0.0.1,localhost,internal.domain";
    }
    // lib.optionalAttrs (httpProxy != "") {
      http_proxy = httpProxy;
      HTTP_PROXY = httpProxy;
    }
    // lib.optionalAttrs (httpsProxy != "") {
      https_proxy = httpsProxy;
      HTTPS_PROXY = httpsProxy;
    }
  );
}
