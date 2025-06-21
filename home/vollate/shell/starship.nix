{ config, lib, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$python"
        "$character"
      ];
      
      directory = {
        style = "blue bold";
        truncation_length = 4;
        truncation_symbol = "…/";
      };
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      
      git_branch = {
        symbol = "🌱 ";
        truncation_length = 4;
        truncation_symbol = "";
      };
      
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      
      cmd_duration = {
        min_time = 4;
        show_milliseconds = false;
        disabled = false;
        style = "bold italic red";
      };
      
      python = {
        symbol = "👾 ";
        pyenv_version_name = true;
      };
    };
  };
} 