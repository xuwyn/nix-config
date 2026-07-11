{
  modules.homeManager.utils = {pkgs, ...}: {
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
}
