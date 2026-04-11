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

    extraConfig.pipewire."10-rates" = {
      "context.properties" = {
        # Default rate for most content; switch to 48000 if your DAC prefers it
        "default.clock.rate" = 96000;
        # All PCM rates supported by the DAC (up to 768kHz)
        # Requires UAC2.0 mode on the DAC — UAC1.0 is capped at 48kHz
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
          352800
          384000
          705600
          768000
        ];
      };
    };
  };

  # Audio packages
  environment.systemPackages = with pkgs; [
    pavucontrol
    pulsemixer
    crosspipe # PipeWire graph editor
  ];
}
