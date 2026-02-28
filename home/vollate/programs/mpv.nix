{
  home,
  pkgs,
  config,
  ...
}:

{
  home.packages = [ pkgs.mpv ];
  xdg.configFile."mpv" = {
    source = ../../../dot-config/.config/mpv;
    recursive = true;
  };
}
