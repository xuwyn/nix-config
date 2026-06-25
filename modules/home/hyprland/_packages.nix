{pkgs, ...}: {
  home.packages = with pkgs; [
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
    hyprpicker # Hyprland color picker
  ];
}
