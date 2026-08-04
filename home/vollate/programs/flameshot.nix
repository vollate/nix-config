{
  config,
  lib,
  pkgs,
  ...
}:

let
  savePath = "${config.home.homeDirectory}/Pictures/Flameshot";
in
{
  home.packages = with pkgs; [
    flameshot
  ];

  xdg.configFile."flameshot/flameshot.ini".text =
    builtins.replaceStrings [ "<Save Path>" ] [ savePath ]
      (builtins.readFile ../../../dot-config/misc/flameshot.conf);

  home.activation.ensureFlameshotSaveDirectory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p ${lib.escapeShellArg savePath}
  '';
}
