{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Steam's bundled Fontconfig cannot parse the modern system conf.d rules.
  # Use only legacy-compatible XML, but expose every configured system font.
  steamFonts = pkgs.writeText "steam-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      ${lib.concatMapStringsSep "\n" (font: "<dir>${font}</dir>") config.fonts.packages}
      <dir>~/.local/share/fonts</dir>
      <dir>~/.fonts</dir>
      <cachedir>~/.cache/fontconfig/steam</cachedir>
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList
          (family: fonts: ''
            <alias binding="strong">
              <family>${family}</family>
              <prefer>
                ${lib.concatMapStringsSep "\n" (font: "<family>${lib.escapeXML font}</family>") fonts}
              </prefer>
            </alias>
          '')
          {
            serif = config.fonts.fontconfig.defaultFonts.serif;
            sans-serif = config.fonts.fontconfig.defaultFonts.sansSerif;
            monospace = config.fonts.fontconfig.defaultFonts.monospace;
            emoji = config.fonts.fontconfig.defaultFonts.emoji;
          }
      )}
    </fontconfig>
  '';
in
{
  environment.systemPackages = [
    (pkgs.steam.override {
      extraEnv = {
        #http_proxy = "http://127.0.0.1:20122";
        #HTTP_PROXY = "http://127.0.0.1:20122";
        #https_proxy = "http://127.0.0.1:20122";
        #HTTPS_PROXY = "http://127.0.0.1:20122";
        FONTCONFIG_FILE = steamFonts;
      };
    })
  ];
}
