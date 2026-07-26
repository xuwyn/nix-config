{pkgs, ...}: {
  home.packages = with pkgs; [
    libnotify # Linux notification tool (provides notify-send)
    wl-clipboard # Wayland clipboard
    cliphist # Clipboard history engine
  ];
}
