{pkgs, ...}: {
  home.packages = with pkgs; [
    libnotify # Linux notification tool (provides notify-send)
    playerctl # Controls Linux media keys via D-Bus
    socat # Network utility (used here for Wayland screenshots)
    wl-clipboard # Wayland clipboard
    cliphist # Clipboard history engine
  ];
}
