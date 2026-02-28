{ config, pkgs, ... }:

{
  home.packages = [ pkgs.aria2 ];

  xdg.configFile."aria2" = {
    source = ../../../dot-config/.config/aria2;
    recursive = true;
  };
}
