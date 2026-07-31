{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.homeManager.xdg) mimeApps;
in {
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;

      defaultApplications = let
        # See: https://github.com/LucasOe/nixos-config/blob/main/modules/home-manager/xdg.nix
        allMimes = lib.splitString "\n" (builtins.readFile "${pkgs.shared-mime-info}/share/mime/types");
        matchingMimes = prefix: builtins.filter (mime: lib.hasPrefix prefix mime) allMimes;
        defaultsFor = prefix: app: lib.genAttrs (matchingMimes prefix) (_: app);

        # Default Applications
        defaultTextEditor = "dev.zed.Zed.desktop";
        defaultImageViewer = "org.gnome.eog.desktop";
        defaultVideoPlayer = "mpv.desktop";
        defaultAudioPlayer = "rhythmbox.desktop";
        defaultBrowser = "firefox.desktop";
        defaultFileManager = "thunar.desktop";

        mediaDefaults = lib.mkMerge [
          (defaultsFor "image/" defaultImageViewer)
          (defaultsFor "video/" defaultVideoPlayer)
          (defaultsFor "audio/" defaultAudioPlayer)
        ];

        manualDefaults = {
          # Directory
          "inode/directory" = defaultFileManager;
          "x-scheme-handler/file" = defaultFileManager;
          # Text
          "application/json" = defaultTextEditor;
          "application/toml" = defaultTextEditor;
          "application/x-sh" = defaultTextEditor;
          "application/x-shellscript" = defaultTextEditor;
          "application/xml" = defaultTextEditor;
          "application/yaml" = defaultTextEditor;
          # Browser
          "x-scheme-handler/http" = defaultBrowser;
          "x-scheme-handler/https" = defaultBrowser;
        };
      in
        lib.mkMerge [mediaDefaults manualDefaults mimeApps];
    };
  };
}
