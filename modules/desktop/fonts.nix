{ config, lib, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # Chinese fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      
      # English fonts
      source-han-sans
      source-han-serif
      
      # Programming fonts
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Iosevka" ]; })
      jetbrains-mono
      fira-code
      fira-code-symbols
      
      # Other useful fonts
      liberation_ttf
      dejavu_fonts
      ubuntu_font_family
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif CJK SC" "Noto Serif" ];
        sansSerif = [ "Noto Sans CJK SC" "Noto Sans" ];
        monospace = [ "JetBrains Mono" "Noto Sans Mono CJK SC" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
} 