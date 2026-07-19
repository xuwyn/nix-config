{pkgs, ...}: {
  home.packages = with pkgs; [
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
