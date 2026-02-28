{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:

{
  home.packages = with pkgs; [
    antidote
  ];

  programs.zsh = {
    enable = true;
    initContent = ''
      # Source shared profile (SSH agent, etc.)
      if [[ -f $ZDOTDIR/profile_shared ]]; then
        source $ZDOTDIR/profile_shared
      fi
      # Source shared zshrc (plugins, completions, p10k, etc.)
      if [[ -f $ZDOTDIR/zshrc_shared ]]; then
        source $ZDOTDIR/zshrc_shared
      fi
    '';
    dotDir = "${config.xdg.configHome}/zsh";
  };

  xdg.configFile = {
    "zsh/zshrc_shared".source = ../../../dot-config/.zshrc;
    "zsh/profile_shared".source = ../../../dot-config/.profile;
    "zsh/.zsh_plugins.txt".source = ../../../dot-config/.zsh_plugins.txt;
    "zsh/shell_func.sh".source = ../../../dot-config/.shell_func.sh;
    "zsh/profile.local".text = ''
      export ANTIDOTE_DIR=${pkgs.antidote}
      export HOST=${hostname}
      export MIXIN_PROXY_PORT=20122
      export VKEY=$HOME/.ssh/vollate_github
      declare -a SSH_KEYCHAIN=("$VKEY")
    '';
  };
}
