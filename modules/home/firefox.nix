{ config, pkgs, username, ... }:

{
  programs.firefox = {
    enable = true;
    # configPath = "${config.home.homeDirectory}/.mozilla/firefox"; #legacy
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    # System-level policies
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      BlockAboutConfig = false;
      # OfferToSaveLogins = false;
    };

    profiles.${username} = {
      name = username;
      isDefault = true;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        old-reddit-redirect
        reddit-enhancement-suite
        tree-style-tab
      ];

      settings = {
        # Enable theming by stylix
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Clean up Firefox Home Content (New Tab Page)
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;
      };
    };
  };
}
