{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    claude-code
    codex
    pi-coding-agent
    openspec
  ];

  # Keep Pi settings writable for /settings and package management.
  home.activation.piFullscreen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings_dir="${config.home.homeDirectory}/.pi/agent"
    settings_file="$settings_dir/settings.json"
    run mkdir -p "$settings_dir"
    if [ -z "''${DRY_RUN_CMD:-}" ]; then
      (
        umask 077
        tmp=$(mktemp "$settings_dir/settings.json.XXXXXX")
        trap 'rm -f "$tmp"' EXIT
        if [ -f "$settings_file" ]; then
          ${pkgs.jq}/bin/jq '. + {tuiMode: "fullscreen"}' "$settings_file" > "$tmp" || exit 1
        else
          printf '%s\n' '{"tuiMode":"fullscreen"}' > "$tmp"
        fi
        mv "$tmp" "$settings_file"
      )
    fi
  '';

  programs.opencode = {
    enable = false;

    extraPackages = with pkgs; [
      nil
      clang-tools
      pyright
      rust-analyzer
      vscode-langservers-extracted
      typescript-language-server
      yaml-language-server
      taplo
      bash-language-server
      dart
      gopls
      lua-language-server
    ];

    settings.lsp = {
      nil = {
        command = [ "nil" ];
        extensions = [ ".nix" ];
      };
      clangd = {
        command = [
          "clangd"
          "--background-index"
          "--clang-tidy"
        ];
        extensions = [
          ".c"
          ".cc"
          ".cpp"
          ".cxx"
          ".c++"
          ".h"
          ".hh"
          ".hpp"
          ".hxx"
          ".h++"
        ];
      };
      pyright = {
        command = [
          "pyright-langserver"
          "--stdio"
        ];
        extensions = [
          ".py"
          ".pyi"
        ];
      };
      rust = {
        command = [ "rust-analyzer" ];
        extensions = [ ".rs" ];
      };
      html = {
        command = [
          "vscode-html-language-server"
          "--stdio"
        ];
        extensions = [
          ".html"
          ".htm"
        ];
      };
      css = {
        command = [
          "vscode-css-language-server"
          "--stdio"
        ];
        extensions = [
          ".css"
          ".scss"
          ".less"
        ];
      };
      typescript = {
        command = [
          "typescript-language-server"
          "--stdio"
        ];
        extensions = [
          ".js"
          ".jsx"
          ".mjs"
          ".cjs"
          ".ts"
          ".tsx"
          ".mts"
          ".cts"
        ];
      };
      json = {
        command = [
          "vscode-json-language-server"
          "--stdio"
        ];
        extensions = [
          ".json"
          ".jsonc"
        ];
      };
      yaml-ls = {
        command = [
          "yaml-language-server"
          "--stdio"
        ];
        extensions = [
          ".yaml"
          ".yml"
        ];
      };
      taplo = {
        command = [
          "taplo"
          "lsp"
          "stdio"
        ];
        extensions = [ ".toml" ];
      };
      bash = {
        command = [
          "bash-language-server"
          "start"
        ];
        extensions = [
          ".sh"
          ".bash"
          ".zsh"
          ".ksh"
        ];
      };
      dart = {
        command = [
          "dart"
          "language-server"
          "--lsp"
        ];
        extensions = [ ".dart" ];
      };
      gopls = {
        command = [ "gopls" ];
        extensions = [ ".go" ];
      };
      lua-ls = {
        command = [ "lua-language-server" ];
        extensions = [ ".lua" ];
      };
    };
  };
}
