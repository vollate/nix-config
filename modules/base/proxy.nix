{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Load the TUN kernel module, required for sing-box to create TUN interfaces.
  boot.kernelModules = [ "tun" ];

  # Add sing-box related packages.
  # This includes the core service and the GUI application.
  environment.systemPackages = with pkgs; [
    sing-box
    (symlinkJoin {
      name = "gui-for-singbox-wayland-fixed";
      paths = [ gui-for-singbox ];
      postBuild = ''
        rm "$out/bin/GUI.for.SingBox"
        cat > "$out/bin/GUI.for.SingBox" <<'EOF'
        #!${runtimeShell}
        set -eu

        runtime_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/GUI.for.SingBox"
        source_bin="${gui-for-singbox}/bin/GUI.for.SingBox"
        runtime_bin="$runtime_dir/GUI.for.SingBox"
        schema_dirs="${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}"

        ${coreutils}/bin/mkdir -p "$runtime_dir"

        if [ ! -e "$runtime_bin" ] || ! ${coreutils}/bin/cmp -s "$source_bin" "$runtime_bin"; then
          ${coreutils}/bin/install -Dm755 "$source_bin" "$runtime_bin.tmp"
          ${coreutils}/bin/mv "$runtime_bin.tmp" "$runtime_bin"
        fi

        export GIO_MODULE_DIR="${glib-networking}/lib/gio/modules/"
        if [ -n "''${XDG_DATA_DIRS:-}" ]; then
          export XDG_DATA_DIRS="$schema_dirs:$XDG_DATA_DIRS"
        else
          export XDG_DATA_DIRS="$schema_dirs"
        fi

        cd "$runtime_dir"
        exec "$runtime_bin" "$@"
        EOF
        chmod +x "$out/bin/GUI.for.SingBox"
      '';
    })
  ];

  # Systemd service disabled - using gui-for-singbox instead
  # systemd.services.sing-box = {
  #   description = "sing-box proxy service";
  #   after = [ "network.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     WorkingDirectory = "/var/lib/sing-box";
  #     ExecStart = "${pkgs.sing-box}/bin/sing-box run -c ${singboxConfig}";
  #     Restart = "on-failure";
  #     RestartSec = 5;
  #     User = "root";
  #     Group = "root";
  #
  #     NoNewPrivileges = false;
  #     ProtectSystem = "strict";
  #     ProtectHome = true;
  #     ReadWritePaths = [ "/var/lib/sing-box" "/tmp" ];
  #     PrivateTmp = true;
  #
  #     AmbientCapabilities = [
  #       "CAP_NET_ADMIN"
  #       "CAP_NET_BIND_SERVICE"
  #       "CAP_NET_RAW"
  #     ];
  #     CapabilityBoundingSet = [
  #       "CAP_NET_ADMIN"
  #       "CAP_NET_BIND_SERVICE"
  #       "CAP_NET_RAW"
  #     ];
  #
  #     PrivateNetwork = false;
  #     PrivateDevices = false;
  #   };
  # };

  # Create state directory with proper permissions (still needed for GUI)
  systemd.tmpfiles.rules = [
    "d /var/lib/sing-box 0755 root root -"
  ];

  # Add the TUN interface to the firewall's trusted interfaces to allow traffic.
  networking.firewall.trustedInterfaces = [
    "Sing-Box"
    "podman0"
  ];

  # Enable IP forwarding for TUN interface
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  services.resolved.enable = false;

  networking.networkmanager.dns = "none";
}
