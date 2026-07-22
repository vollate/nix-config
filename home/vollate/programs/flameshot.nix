{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    flameshot
  ];

  xdg.configFile."flameshot/flameshot.ini".text =
    builtins.replaceStrings [ "<Save Path>" ] [ "${config.home.homeDirectory}/Pictures/Flameshot" ]
      (builtins.readFile ../../../dot-config/misc/flameshot.conf);
}
