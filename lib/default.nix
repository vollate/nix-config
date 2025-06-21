# Custom library functions and utilities
# This file contains helper functions used across the configuration

{ lib, inputs, ... }:

rec {
  # Helper function to create NixOS configurations
  mkSystem = {
    hostname,
    system ? "x86_64-linux",
    username,
    modules ? [],
    extraModules ? [],
    desktop ? null,
    overlays ? [],
  }: inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    
    specialArgs = {
      inherit inputs hostname username desktop;
    };
    
    modules = modules ++ extraModules ++ [
      ../hosts/${hostname}
      ../users/${username}.nix
      
      # Apply overlays
      {
        nixpkgs.overlays = overlays;
      }
      
      # Home Manager integration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "backup";  # 自动备份冲突文件
          extraSpecialArgs = { inherit inputs hostname username desktop; };
          users.${username} = import ../home/${username};
        };
      }
    ];
  };

  # Helper function to create system configuration with default modules
  mkHost = args: mkSystem (args // {
    modules = [
      ../modules/base
      ../modules/desktop
      ../modules/development
      # Add VSCode Server support
      inputs.vscode-server.nixosModules.default
    ] ++ (args.modules or []);
  });
} 