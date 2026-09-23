{
  lib,
  pkgs,
  ...
}:

let
  coding-tools-mcp = pkgs.python3Packages.buildPythonApplication rec {
    pname = "coding-tools-mcp";
    version = "0.3.0";
    pyproject = true;

    src = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/ed/b5/72f9e77a382bc08558ebe09cc5dffd406808563471efc5c50f4fe1c5ef05/coding_tools_mcp-0.3.0.tar.gz";
      hash = "sha256-/bPF9uiYABcJe4XVqOqReYJd9Im5weFK/xx4/p2LiwU=";
    };

    # nixpkgs currently supplies setuptools 83 while upstream pins its build
    # backend below 77. The source builds successfully with 83; this only
    # relaxes the build-time upper bound, not a runtime dependency.
    postPatch = ''
      substituteInPlace pyproject.toml --replace-fail 'setuptools>=68,<77' 'setuptools>=68'
    '';

    build-system = [ pkgs.python3Packages.setuptools ];
    dependencies = [ pkgs.python3Packages.pyjwt ];

    pythonImportsCheck = [ "coding_tools_mcp" ];
  };

  servicePath = lib.makeBinPath (
    with pkgs;
    [
      bash
      coreutils
      git
      nix
      gcc
      clang
      cmake
      ninja
      pkg-config
      python3
      cargo
      rustc
      nodejs
      pnpm
    ]
  );
in
{
  home.packages = [ coding-tools-mcp ];

  # A user unit keeps the MCP server in vollate's user context.  It deliberately
  # has one workspace: upstream treats each server process as one trust domain.
  systemd.user.services.coding-tools-mcp = {
    Unit = {
      Description = "Coding Tools MCP server";
      After = [ "network-online.target" ];
    };

    Service = {
      ExecStart = "${coding-tools-mcp}/bin/coding-tools-mcp --host 127.0.0.1 --port 8765 --permission-mode trusted --workspace /home/vollate/nix-config";
      Environment = [
        "HOME=/home/vollate"
        "PATH=${servicePath}"
        # NixOS packages and toolchains resolve through /nix/store; upstream
        # adds this as a Landlock read/execute root for exec_command.
        "CODING_TOOLS_MCP_EXEC_ALLOW_ROOTS=/nix/store"
        # Keep exec_command to the Nix-defined PATH and other core variables;
        # do not import the interactive shell environment.
        "CODING_TOOLS_MCP_SHELL_ENV_INHERIT=core"
        "CODING_TOOLS_MCP_TELEMETRY=off"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
