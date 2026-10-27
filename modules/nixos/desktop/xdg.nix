{
  hjemCompat = true;
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    lib,
    ...
  }: let
    userDirs = {
      DOWNLOAD = "Downloads";
      DOCUMENTS = "Documents";
      PICTURES = "Pictures";
      MUSIC = "Music";
      VIDEOS = "Videos";
      SCREENSHOTS = "Pictures/Screenshots";
    };
  in {
    environment.systemPackages = with pkgs; [
      xdg-user-dirs
      xdg-user-dirs-gtk
    ];

    hj = {
      xdg.config.files."user-dirs.dirs".text = lib.concatLines (
        lib.mapAttrsToList (k: v: ''XDG_${k}_DIR="$HOME/${v}"'') userDirs
      );
      files = lib.mapAttrs' (_: v: lib.nameValuePair v {type = "directory";}) userDirs;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
      config.umbriel = {
        # zed needs these
        "org.freedesktop.portal.FileChooser" = ["gtk"];
        "org.freedesktop.portal.OpenURI" = ["gtk"];
      };
    };

    hj.xdg.mime-apps.default-applications = let
      # NOTE: This is IFD but harmless since the path is cached and eval just substitutes it
      # IFD-free alternative is a runCommand that builds mimeapps.list
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
      lib.mkMerge [mediaDefaults manualDefaults];
  };
}
