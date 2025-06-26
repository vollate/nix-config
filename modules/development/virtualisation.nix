{ config, lib, pkgs, ... }:

{
  # Enable virtualization
  virtualisation = {
    # Enable libvirtd for KVM/QEMU
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };

    # Enable VirtualBox (optional, uncomment if needed)
    # virtualbox.host.enable = true;

    # Enable Podman as Docker alternative
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Virtualization packages
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
    qemu
    OVMF

    # Podman tools
    podman-compose
    #podman-desktop
  ];

  # Enable SPICE USB redirection
  services.spice-vdagentd.enable = true;
}
