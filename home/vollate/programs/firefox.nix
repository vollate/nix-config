{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [ pkgs.passff-host ];

    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      settings = {
        "toolkit.tabbox.switchByScrolling" = true;
        "identity.fxaccounts.enabled" = true;
        "browser.tabs.warnOnClose" = false;
        "browser.startup.page" = 3;

        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.av1.enabled" = true;
      };
    };
  };
}
