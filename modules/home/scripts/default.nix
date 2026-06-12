{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) terminal;
in {
  home.packages = [
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
    icon = terminal;
    settings.StartupWMClass = "dropterminal";
    categories = ["System" "Utility" "TerminalEmulator"];
  };
}
