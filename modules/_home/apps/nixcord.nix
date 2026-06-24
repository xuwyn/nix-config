{
  inputs,
  host,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  barChoice = vars.barChoice or "";
in {
  imports = [inputs.nixcord.homeModules.nixcord];

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
        if barChoice == "noctalia"
        then ["noctalia-material.theme.css" "noctalia.theme.css"]
        else ["stylix.theme.css"];
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
}
