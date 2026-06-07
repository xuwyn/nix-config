{pkgs, ...}: {
  home.packages = [
    (import ./emopicker9000.nix {inherit pkgs;})
    (import ./DropTerminal.nix {inherit pkgs;})
    (import ./web-search.nix {inherit pkgs;})
    (import ./hyprland-float-all.nix {inherit pkgs;})
    (import ./hyprland-change-layout.nix {inherit pkgs;})
  ];

  xdg.desktopEntries.dropterminal = {
    name = "Drop Terminal";
    comment = "Dropdown terminal (Hyprland)";
    exec = "DropTerminal";
    terminal = false;
    type = "Application";
    icon = "kitty";
    settings.StartupWMClass = "dropterminal";
    categories = ["System" "Utility" "TerminalEmulator"];
  };
}
