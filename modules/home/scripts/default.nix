{
  pkgs,
  host,
  ...
}: let
  inherit (import ../../../hosts/${host}/variables.nix) kittyEnable;
in {
  home.packages =
    [
      (import ./rofi-launcher.nix {inherit pkgs;})
      (import ./web-search.nix {inherit pkgs;})
      (import ./hyprland-float-all.nix {inherit pkgs;})
      (import ./hyprland-change-layout.nix {inherit pkgs;})
    ]
    ++ ( # default fallback only works with kitty
      if kittyEnable
      then [(import ./DropTerminal.nix {inherit pkgs;})]
      else []
    );

  xdg.desktopEntries =
    if kittyEnable
    then {
      dropterminal = {
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
    else {};
}
