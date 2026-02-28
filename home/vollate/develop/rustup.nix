{ config, pkgs, ... }:

{
  home.sessionVariables = {
    RUSTUP_DIST_SERVER = "https://mirrors.ustc.edu.cn/rust-static";
    RUSTUP_UPDATE_ROOT = "https://mirrors.ustc.edu.cn/rust-static/rustup";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  home.file.".cargo/config.toml".text = ''
    [source.crates-io]
    replace-with = 'ustc'

    [source.ustc]
    registry = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"

    [registries.ustc]
    index = "sparse+https://mirrors.ustc.edu.cn/crates.io-index/"
  '';
}
