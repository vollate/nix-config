{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable PulseAudio in favor of PipeWire
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Use the example session manager (no others are packaged yet)
    # wireplumber is the default session manager since NixOS 22.05
    # media-session.enable = true;
  };

  # Audio packages
  environment.systemPackages = with pkgs; [
    pavucontrol
    pulsemixer
    crosspipe # PipeWire graph editor
  ];
}
