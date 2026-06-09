{
  host,
  pkgs,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  hyprlandEnable = vars.hyprlandEnable or false;
  barChoice = vars.barChoice or "noctalia";

  # Noctalia-specific packages
  noctaliaPkgs =
    if barChoice == "noctalia"
    then
      with pkgs; [
        matugen # color palette generator needed for noctalia-shell
        evtest # read kb input for bongo cat
      ]
    else [];
in {
  home.packages = with pkgs;
    [
      # --- Dev Stuffs ---
      alejandra # Nix formatter
      nixfmt # Nix formatter
      pkg-config # Build dependency helper
      python3

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

      # --- Font
      maple-mono.NF # kitty
    ]
    ++ (
      if hyprlandEnable
      then
        [
          # --- Desktop Apps ---
          gimp # Photo editor
          mpv # Video player
          picard # Music tagger GUI
          rhythmbox # Music player GUI
          eog # GNOME Image viewer (GTK based)
          file-roller # GNOME Archive manager interface
          pavucontrol # PulseAudio/PipeWire volume panel

          # --- Wayland/Hyprland/Rofi ---
          app2unit # Launches Linux desktop entries as systemd user units
          cliphist # Clipboard history engine
          libnotify # Linux notification tool (provides notify-send)
          playerctl # Controls Linux media keys via D-Bus
          socat # Network utility (used here for Wayland screenshots)
          wl-clipboard # Wayland clipboard
        ]
        ++ noctaliaPkgs
      else []
    );
}
