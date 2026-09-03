{
  modules.homeManager.cli = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    leaves = pkgs.rustPlatform.buildRustPackage {
      pname = pkgs.sources.leaves.pname;
      version = pkgs.sources.leaves.version;
      src = pkgs.sources.leaves.src;
      cargoLock = pkgs.sources.leaves.cargoLock."Cargo.lock";
    };
  in {
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
        leaves # tui disk usage
        inputs.ncr.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
