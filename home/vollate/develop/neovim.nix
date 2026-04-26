{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    neovim-with-nodejs

    ripgrep
    fd
    tree-sitter

    (writeShellScriptBin "vim" "exec nvim \"$@\"")
    (writeShellScriptBin "vi" "exec nvim \"$@\"")
  ];

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/dot-config/.config/nvim";

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
