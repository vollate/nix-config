{ pkgs, ... }:

let
  pars-cli = pkgs.callPackage ../../packages/pars-cli { };
in
{
  environment.systemPackages = [
    pars-cli
  ];
}
