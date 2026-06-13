{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking = {
    # sing-box TUN uses policy routing; strict reverse-path filtering can drop
    # packets on asymmetric TUN/direct paths.
    firewall.checkReversePath = "loose";

    # Keep DHCP-provided DNS, but make glibc resolver retries less painful when
    # sing-box TUN is debugging or restarting.
    resolvconf.extraOptions = [
      "ndots:1"
      "timeout:2"
      "attempts:2"
    ];
  };
}
