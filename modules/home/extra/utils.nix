{
  flake.modules.homeManager.utils = {pkgs, ...}: {
    home.packages = with pkgs; [
      # --- Terminal Utilities ---
      htop # System monitor
      duf # Disk utility (disk space)
      dysk # Disk utility (disk formatting info)
      ncdu # Interactive disk space analyzer
      mdcat # Markdown viewer for terminal
      ffmpeg # Audio/Video processing CLI
      ytmdl # YouTube audio downloader
      unrar # Archive unpacker
      zip # Compressor
      unzip # Unpacker
      tree # print directory
      gnugrep # grep cmd
    ];
  };
}
