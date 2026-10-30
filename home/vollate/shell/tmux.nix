{ pkgs, ... }:

{
  # Oh My Tmux owns configuration and TPM plugins on every platform.
  # Do not enable programs.tmux: its generated config would duplicate these settings.
  home.packages = with pkgs; [
    tmux
    perl
    git
    curl
  ];

  xdg.configFile = {
    "tmux/tmux.conf".source = ../../../dot-config/.tmux/.tmux.conf;
    "tmux/tmux.conf.local".source = ../../../dot-config/.tmux.conf.local;
  };
}
