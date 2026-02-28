{
  config,
  lib,
  pkgs,
  ...
}:

{
  fonts = {
    packages = with pkgs; [
      # Chinese fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      # English fonts
      source-han-sans
      source-han-serif

      # Programming fonts / Nerd Fonts (包含 Powerline 图标如 \ue0c6)
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.hack
      nerd-fonts.noto
      fira-code
      fira-code-symbols

      # Other useful fonts
      liberation_ttf
      dejavu_fonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif CJK SC"
          "Noto Serif"
        ];
        sansSerif = [
          "Noto Sans CJK SC"
          "Noto Sans"
        ];
        monospace = [
          "JetBrainsMono Nerd Font" # 使用 Nerd Font 版本以支持 Powerline 图标
          "Noto Sans Mono CJK SC"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
