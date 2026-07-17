{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    #claude-code
    codex
    openspec
  ];

  programs.opencode = {
    enable = true;

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
