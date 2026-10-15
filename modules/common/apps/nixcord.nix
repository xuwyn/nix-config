{
  tags = ["desktop"];
  module = {
    config,
    lib,
    inputs,
    users,
    system,
    ...
  }: let
    cfg = config.custom.nixcord;
    class =
      if lib.hasSuffix "-darwin" system
      then "darwinModules"
      else "nixosModules";
  in {
    imports = [inputs.nixcord.${class}.nixcord];

    options.custom.nixcord = {
      noctaliaThemeEnabled = lib.mkEnableOption "Enable the noctalia.theme.css local theme";
    };

    config.programs.nixcord = {
      enable = lib.mkDefault true;
      user = lib.head users;

      discord.vencord.enable = false;
      discord.equicord.enable = true;

      config = {
        enabledThemes =
          if cfg.noctaliaThemeEnabled
          then ["noctalia.theme.css"]
          else ["catppuccin-mocha.theme.css"];
        enabledThemeLinks = lib.optionals (!cfg.noctaliaThemeEnabled) ["https://raw.githubusercontent.com/catppuccin/discord/main/themes/mocha.theme.css"];
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
  };
}
