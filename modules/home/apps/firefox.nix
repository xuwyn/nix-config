{
  flake.modules.homeManager.apps = {
    inputs,
    config,
    pkgs,
    username,
    lib,
    ...
  }: let
    cfg = config.homeManager.apps.firefox;
    inherit (inputs.firefox-addons.lib.${pkgs.stdenv.hostPlatform.system}) buildFirefoxXpiAddon;
    #   pywalfox = buildFirefoxXpiAddon rec {
    #     pname = "pywalfox";
    #     version = "2.1.0";
    #     addonId = "pywalfox@frewacom.org";
    #     url = "https://addons.mozilla.org/firefox/downloads/file/4651382/pywalfox-2.1.0.xpi";
    #     sha256 = "sha256-GkqMhj46mFN2RnBxK04frKaH0w0FZlXxVmnHqxA8weU=";
    #     meta = with lib; {
    #       homepage = "https://github.com/Frewacom/pywalfox.com";
    #       platforms = platforms.all;
    #     };
    #   };
  in {
    options.homeManager.apps.firefox = {
      enable = lib.mkEnableOption "Enable firefox user profile";
    };
    config = lib.mkIf cfg.enable {
      # home.packages = with pkgs; [
      #   pywalfox-native
      # ];

      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";

        # System-level policies
        policies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          BlockAboutConfig = false;
          OfferToSaveLogins = false;
        };

        # nativeMessagingHosts = [pkgs.pywalfox-native];

        profiles.${username} = {
          name = username;
          isDefault = true;

          extensions.force = true; # enable overwrite
          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons;
            [
              ublock-origin
              old-reddit-redirect
              reddit-enhancement-suite
              tree-style-tab
              don-t-fuck-with-paste
              return-youtube-dislikes
              youtube-nonstop
              darkreader
              ctrl-number-to-switch-tabs
            ]
            ++ (with customAddons; [
              # pywalfox
            ]);

          settings = {
            # Enable theming by stylix
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

            # Clean up Firefox Home Content (New Tab Page)
            "browser.newtabpage.activity-stream.nova.enabled" = false;
            "browser.newtabpage.activity-stream.feeds.weatherfeed" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.showWeather" = false;
            "browser.newtabpage.activity-stream.showSearch" = false;
            "browser.newtabpage.activity-stream.system.showWeather" = false;
            "browser.newtabpage.activity-stream.widgets.system.weather.enabled" = false;
            "browser.newtabpage.activity-stream.widgets.weather.enabled" = false;

            # Resume previous browser session
            "browser.startup.page" = 3;
          };
        };
      };
    };
  };
}
