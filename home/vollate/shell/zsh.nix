{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    
    shellAliases = {
      ll = "exa -l";
      la = "exa -la";
      ls = "exa";
      cat = "bat";
      grep = "rg";
      find = "fd";
      cd = "z";
      
      # Git aliases
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gs = "git status";
      gd = "git diff";
      
      # NixOS aliases
      rebuild = "sudo nixos-rebuild switch --flake .";
      upgrade = "sudo nixos-rebuild switch --upgrade --flake .";
      cleanup = "sudo nix-collect-garbage -d";
    };
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "systemd"
      ];
    };
    
    initExtra = ''
      # Zoxide integration
      eval "$(zoxide init zsh)"
      
      # Starship prompt
      eval "$(starship init zsh)"
    '';
  };
} 