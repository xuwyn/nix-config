{
  flake.modules.homeManager.apps = {
    inputs,
    lib,
    config,
    ...
  }: let
    cfg = config.homeManager.apps.nixcord;
    isMatugenEnabled = config.programs.matugen.enable or false;
  in {
    options.homeManager.apps.nixcord = {
      enable = lib.mkEnableOption "Enble Nixcord";
      themes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Set theme.css list for nixcord";
      };
    };

    imports = [inputs.nixcord.homeModules.nixcord];

    config = lib.mkIf cfg.enable {
      # Nixcord options: https://flameflag.github.io/nixcord/
      programs.nixcord = {
        enable = true;

        # Choose your client (enable only one of these two)
        discord.vencord.enable = false; # Standard Vencord
        discord.equicord.enable = true; # Equicord (has more plugins)

        # vesktop.enable = true;
        # dorian.enable = true;
        # legcord.enable = true;

        config = {
          enabledThemes =
            if cfg.themes != []
            then cfg.themes
            else if isMatugenEnabled
            then ["midnight-discord.css"]
            else [];
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
            favoriteGifSearch.enable = true;
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
    };
  };
}
