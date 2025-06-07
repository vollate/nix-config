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
#     substituers will be appended to the default substituters when fetching packages
#     nix com    extra-substituters = [munity's cache server
#     extra-substituters = [
#      "https://nix-community.cachix.org"
#     ];
#     extra-trusted-public-keys = [
#      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
#     ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    nixpkgs-ollama.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "github:nix-community/home-manager/release-24.11";

      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs dependencies.
      inputs.nixpkgs.follows = "nixpkgs";
    };
#     catppuccin-bat = {
#       url = "github:catppuccin/bat";
#       flake = false;
#     };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
#     home-manager,
    ...
  }: {
    nixosConfigurations = {
      tb-amd-6800h = let
        username = "vollate";
        specialArgs = {inherit username;};
      in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          system = "x86_64-linux";

          modules = [
            ./hosts/tb-amd-6800h
            ./users/${username}.nix

#             home-manager.nixosModules.home-manager
#             {
#              home-manager.useGlobalPkgs = true;
#              home-manager.useUserPackages = true;
#
#              home-manager.extraSpecialArgs = inputs // specialArgs;
#              home-manager.users.${username} = import ./users/${username}/home.nix;
#             }
          ];
        };
    };
  };
}
