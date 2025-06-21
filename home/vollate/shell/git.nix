{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "vollate";
    userEmail = "your.email@example.com"; # 请替换为您的邮箱
    
    extraConfig = {
      init.defaultBranch = "main";
      push.default = "current";
      pull.rebase = true;
      core.editor = "nvim";
      merge.tool = "vimdiff";
      
      # Better diff algorithm
      diff.algorithm = "patience";
      
      # Use separate file for local git config
      include.path = "~/.gitconfig.local";
    };
    
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      df = "diff";
      dc = "diff --cached";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
    };
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };
} 