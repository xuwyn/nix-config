{
  host,
  pkgs,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  hyprlandEnable = vars.hyprlandEnable or false;
  i3Enable = vars.i3Enable or false;
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

          # --- Hyprland Helpers ---
          app2unit # Launches Linux desktop entries as systemd user units
          libnotify # Linux notification tool (provides notify-send)
          playerctl # Controls Linux media keys via D-Bus
          socat # Network utility (used here for Wayland screenshots)
          wl-clipboard # Wayland clipboard
          cliphist # Clipboard history engine
          grim # Grabs image data from the screen
          slurp # Select rectangle region on the screen
          swappy # GUI to edit screenshots
          ydotool # Simulates mouse and kb inputs
          hyprpolkitagent # root pwd and auth prompts
          hyprshot # Hyprland screenshot script
          # hyprshutdown # Hyprland power-off menu
          hyprpicker # Hyprland color picker
          # hyprland-qtutils # needed for banners and ANR messages
        ]
        ++ noctaliaPkgs
      else []
    )
    ++ (
      if i3Enable
      then [
        ddcutil # Monitor brightness
        i3-volume # audio control with notifications
        playerctl # Media player for polybar
        pavucontrol # volume control
        pulseaudio # sound server
        libnotify # Linux notification tool (provides notify-send)
        app2unit # systemd user app launcher
        feh # set background image
        haskellPackages.greenclip # clipboard
        xrandr # x11 monitor settings
        xinput # x11 mouse & touchpad settings
        networkmanagerapplet # nm-connection-editor
        # i3lock-color # install from src via host pc
        maim # cli screenshot utility
        slop # region selection for screenshot
        xclip # access X clipboard for screenshot
        eog # GNOME Image viewer (GTK based)
      ]
      else []
    );
}
