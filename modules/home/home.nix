{
  flake.modules.homeManager.home = {
    username,
    pkgs,
    ...
  }: {
    home = {
      username = username;
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/${username}"
        else "/home/${username}";
      stateVersion = "23.11"; # Do not change!
      sessionPath = ["$HOME/.local/bin"];
    };

    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      # --- Dev Stuffs ---
      alejandra # Nix formatter
      nixfmt # Nix formatter
      pkg-config # Build dependency helper
      jq # json parser

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

      # --- Eye-candy ---
      onefetch # fastfetch for git repo
      eza # Beautiful ls replacement
      lolcat # Rainbow text
      cowsay # Fun text layout
      cmatrix # Raining text matrix
      asciiquarium-transparent # fish tank
      cbonsai # bonsai tree growing
      pipes # pipes screensaver
      fortune # pseudorandom messages
      taoup # same as fortune
    ];
  };
}
