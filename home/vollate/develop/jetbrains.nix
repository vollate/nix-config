{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs.jetbrains; [
    webstorm
    clion
    goland
    pycharm
    rust-rover
  ];
}
