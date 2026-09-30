{
  modules = let
    mkNixcordSettings = lib: cfg: {
      discord.vencord.enable = false;
      discord.equicord.enable = true;

      config = {
        enabledThemes = cfg.themes;
        enabledThemeLinks = lib.optionals (cfg.themes == []) ["https://raw.githubusercontent.com/catppuccin/discord/main/themes/mocha.theme.css"];
        plugins = {
          alwaysAnimate.enable = true;
          betterGifAltText.enable = true;
          clearUrls.enable = true;
          disableDeepLinks.enable = true;
          fakeNitro = {
            enable = true;
            disableEmbedPermissionCheck = true;
            enableEmojiBypass = true;
            enableStickerBypass = true;
            enableStreamQualityBypass = true;
            transformCompoundSentence = true;
            transformEmojis = true;
            transformStickers = true;
            useEmojiHyperLinks = true;
            useStickerHyperLinks = true;
          };
          gameActivityToggle.enable = true;
          gifPaste.enable = true;
          greetStickerPicker.enable = true;
          ignoreActivities = {
            enable = true;
            ignoreCompeting = true;
            ignoreListening = true;
            ignorePlaying = true;
            ignoreStreaming = true;
            ignoreWatching = true;
          };
          youtubeAdblock.enable = true;
          openInApp.enable = true;
        };
      };
    };

    mkSystemNixcordModule = class: {
      config,
      lib,
      inputs,
      users,
      ...
    }: let
      cfg = config.${class}.apps.nixcord;
    in {
      imports = [inputs.nixcord.${"${class}Modules"}.nixcord];

      options.${class}.apps.nixcord = {
        enable = lib.mkEnableOption "Enable Nixcord (Equicord)";
        themes = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Enabled local themes, falls back to catppuccin mocha if empty";
        };
      };

      config = lib.mkIf cfg.enable {
        programs.nixcord =
          (mkNixcordSettings lib cfg)
          // {
            enable = true;
            user = lib.head users;
          };
      };
    };
  in {
    nixos.apps = mkSystemNixcordModule "nixos";
    darwin.apps = mkSystemNixcordModule "darwin";
  };
}
