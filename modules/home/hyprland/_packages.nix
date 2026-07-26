{pkgs, ...}: {
  home.packages = with pkgs; [
    # --- Hyprland Helpers ---
    app2unit # Launches Linux desktop entries as systemd user units
    libnotify # Linux notification tool (provides notify-send)
    wl-clipboard # Wayland clipboard
    cliphist # Clipboard history engine
    hyprshot # Hyprland screenshot script
    hyprpicker # Hyprland color picker
  ];
}
