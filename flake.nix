{
  description = "NixOS configuration by Vollate";

  ##################################################################################################################
  #
  # Want to know Nix in details? Looking for a beginner-friendly tutorial?
  # Check out https://github.com/ryan4yin/nixos-and-flakes-book !
  #
  ##################################################################################################################

  # the nixConfig here only affects the flake itself, not the system configuration!
  nixConfig = {
    # Binary cache mirrors for China
    extra-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add more inputs as needed
    # catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: 
  let
    # Import our custom library
    myLib = import ./lib { inherit (nixpkgs) lib; inherit inputs; };
    
    # Import overlays
    overlays = import ./overlays;
  in
  {
    # NixOS configurations
    nixosConfigurations = {
      # Desktop with Plasma
      tb-amd-6800h = myLib.mkHost {
        hostname = "tb-amd-6800h";
        username = "vollate";
        desktop = "plasma";
        system = "x86_64-linux";
        overlays = overlays; # 应用 overlays
      };
      
      # Add more hosts here as needed
      # server = myLib.mkHost {
      #   hostname = "server";
      #   username = "vollate";
      #   desktop = null; # No desktop environment
      #   modules = [
      #     ./modules/server
      #   ];
      # };
    };

    # Development shells
    devShells = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nil  # Nix language server
            nixfmt-classic
            git
          ];
          shellHook = ''
            echo "Welcome to NixOS configuration development environment!"
            echo "Available commands:"
            echo "  nil          - Nix language server"
            echo "  nixfmt-classic - Nix formatter"
          '';
        };
      }
    );

    # Formatter for nix fmt
    formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" ] (system:
      nixpkgs.legacyPackages.${system}.nixfmt-classic
    );
  };
}
