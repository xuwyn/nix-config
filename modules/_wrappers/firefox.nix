{
  types,
  flakeInputs,
  ...
} @ adios: {
  options = {
    extraPolicies = {
      type = types.attrs;
      default = {};
      description = "Host-specific policies, shallow-merged over the defaults";
    };

    policies.default = adios.promise ({
      inputs,
      options,
    }: let
      pkgs = inputs.nixpkgs.pkgs;
      lib = pkgs.lib;

      nurExpressions = import flakeInputs.nur-expressions {inherit pkgs;};
      buildMozillaXpiAddon = nurExpressions.lib.mozilla.mkBuildMozillaXpiAddon {
        inherit (pkgs) fetchurl stdenv;
      };
      rycee = nurExpressions.firefox-addons;

      duckduckgo-no-ai-search = buildMozillaXpiAddon {
        pname = "duckduckgo-no-ai-search";
        version = "2026.6.5";
        addonId = "noai@duckduckgo.com";
        url = "https://addons.mozilla.org/firefox/downloads/file/4838098/duckduckgo_no_ai_search-2026.6.5.xpi";
        sha256 = "sha256-KEj36AcTlR/FTR5i5BiDW+ShlXBx2+04cCy6TqSp0Kg=";
        meta = {
          homepage = "https://noai.duckduckgo.com";
          platforms = lib.platforms.all;
        };
      };

      sink-it-for-reddit = buildMozillaXpiAddon {
        pname = "sink-it-for-reddit";
        version = "8.6.0";
        addonId = "{09acf9ff-55d4-4366-a1a9-c9b3c8877c09}";
        url = "https://addons.mozilla.org/firefox/downloads/file/4913795/sink_it_for_reddit-8.6.0.xpi";
        sha256 = "sha256-L6sQXoPH+BadLbHVeWElE3rAGpKR9bByrBKSygeeHpk=";
        meta.platforms = lib.platforms.all;
      };

      extensions = [
        duckduckgo-no-ai-search
        sink-it-for-reddit
        rycee.ublock-origin
        rycee.don-t-fuck-with-paste
        rycee.return-youtube-dislikes
        rycee.youtube-nonstop
        rycee.darkreader
        rycee.ctrl-number-to-switch-tabs
        rycee.pywalfox
      ];

      mkExtension = pkg: {
        name = pkg.addonId;
        value = {
          installation_mode = "force_installed";
          install_url = "file://${pkg}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${pkg.addonId}.xpi";
        };
      };
    in
      {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        OfferToSaveLogins = false;

        # browser.startup.page = 3
        Homepage.StartPage = "previous-session";

        FirefoxHome = {
          Search = false;
          TopSites = false;
          SponsoredTopSites = false;
          Pocket = false;
          SponsoredPocket = false;
          Stories = false;
          SponsoredStories = false;
        };

        Preferences = {
          # needed for userChrome/userContent (pywalfox)
          "toolkit.legacyUserProfileCustomizations.stylesheets" = {
            Value = true;
            Status = "default";
          };
          "browser.newtabpage.activity-stream.widgets.weather.enabled" = {
            Value = false;
            Status = "default";
          };
          "browser.newtabpage.activity-stream.hideLogo" = {
            Value = true;
            Status = "default";
          };
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = {
            Value = false;
            Status = "default";
          };
        };

        ExtensionSettings = builtins.listToAttrs (map mkExtension extensions);
      }
      // options.extraPolicies);
  };
}
