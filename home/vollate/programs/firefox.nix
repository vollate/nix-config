{ config, lib, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    
    # Firefox preferences
    profiles.default = {
      id = 0;
      name = "default";
      isDefault = true;
      
      # Extensions (commented out until NUR is configured)
      # extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      #   ublock-origin
      #   bitwarden
      #   privacy-badger
      # ];
      
      settings = {
        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        
        # Performance
        "browser.sessionstore.warnOnQuit" = false;
        "browser.startup.page" = 3; # Restore previous session
        
        # UI
        "browser.tabs.warnOnClose" = false;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
      };
    };
  };
} 