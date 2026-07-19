{pkgs, ...}: {
  home.packages = with pkgs; [
    ddcutil # Monitor brightness
    i3-volume # audio control with notifications
    playerctl # Media player for polybar
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
  ];
}
