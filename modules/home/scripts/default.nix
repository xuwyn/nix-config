{
  pkgs,
  host,
  username,
  config,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  hyprlandEnable = vars.hyprlandEnable or false;
  i3Enable = vars.i3Enable or false;
  kittyEnable = vars.kittyEnable or false;
  stylixImage = vars.stylixImage;
in {
  home.packages =
    [
      (import ./rofi-launcher.nix {inherit pkgs;})
      (import ./web-search.nix {inherit pkgs;})
    ]
    ++ (
      if hyprlandEnable
      then
        [
          (import ./hyprland-float-all.nix {inherit pkgs;})
          (import ./hyprland-change-layout.nix {inherit pkgs;})
        ]
        ++ ( # default fallback only works with kitty
          if kittyEnable
          then [(import ./DropTerminal.nix {inherit pkgs;})]
          else []
        )
      else []
    )
    ++ (
      if i3Enable
      then [
        (import ./media-status.nix {inherit pkgs;})
        (import ./polybar-launcher.nix {inherit pkgs;})
        (import ./tap-to-click.nix {inherit pkgs;})
        (import ./natural-scroll.nix {inherit pkgs;})
        (import ./set-refresh-rates.nix {inherit pkgs host;})
        (import ./i3-lock.nix {inherit pkgs stylixImage config;})
        (import ./powermenu {inherit pkgs username;})
      ]
      else []
    );

  # Helper files
  home.file =
    if i3Enable
    then {
      ".config/rofi/powermenu/type-4/style-3.rasi" = import ./powermenu/style-3.nix;
      ".config/rofi/powermenu/type-4/shared/confirm.rasi" = import ./powermenu/confirm.nix {inherit config;};
    }
    else {};

  xdg.desktopEntries =
    if hyprlandEnable && kittyEnable
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
