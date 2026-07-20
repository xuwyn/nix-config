{
  modules.homeManager.cli = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.homeManager.cli.utils = {
      enable = lib.mkEnableOption "Add extra cli utils";
    };
    config = lib.mkIf config.homeManager.cli.utils.enable {
      home.packages = with pkgs; [
        # --- Terminal Utilities ---
        duf # Disk utility (disk space)
        dysk # Disk utility (disk formatting info)
        ncdu # Interactive disk space analyzer
        mdcat # Markdown viewer for terminal
        ffmpeg # Audio/Video processing CLI
        ytmdl # YouTube audio downloader
        unrar # Archive unpacker
        zip # Compressor
        unzip # Unpacker
        gnugrep # grep cmd
        jq # json processor
      ];
    };
  };
}
