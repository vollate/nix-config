# Neovim editor module
# Provides optional Node.js support configuration

{ config, lib, pkgs, ... }:

let cfg = config.programs.neovim-custom;
in {
  options.programs.neovim-custom = {
    enable = lib.mkEnableOption "Enable custom Neovim configuration";

    withNodejs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Node.js for coc-nvim support";
    };

    extraPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = "Extra packages to include with Neovim";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        # Basic Neovim
        neovim

        # Basic tools
        ripgrep
        fd

        # Conditionally include Node.js
      ] ++ lib.optionals cfg.withNodejs [ nodejs npm ] ++ cfg.extraPackages;

    # Set default editor
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # Shell aliases
    programs.bash.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };

    programs.zsh.shellAliases = {
      vi = "nvim";
      vim = "nvim";
    };
  };
}
