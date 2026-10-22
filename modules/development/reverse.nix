{ pkgs, ... }:

{
  # Reverse engineering tools shared by all development hosts.
  environment.systemPackages = with pkgs; [
    radare2
  ];
}
