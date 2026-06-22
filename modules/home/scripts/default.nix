{
  pkgs,
  lib,
  host,
  username,
  config,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  i3Enable = vars.i3Enable or false;
  stylixImage = vars.stylixImage;
in {
  home.packages =
    [
      (import ./rofi-launcher.nix {inherit pkgs;})
      (import ./web-search.nix {inherit pkgs;})
    ]
    ++ lib.optionals i3Enable [
      (import ./media-status.nix {inherit pkgs;})
      (import ./polybar-launcher.nix {inherit pkgs;})
      (import ./tap-to-click.nix {inherit pkgs;})
      (import ./natural-scroll.nix {inherit pkgs;})
      (import ./set-refresh-rates.nix {inherit pkgs host;})
      (import ./i3-lock.nix {inherit pkgs stylixImage config;})
      (import ./powermenu {inherit pkgs username;})
    ];

  # Helper files
  home.file = lib.mkIf i3Enable {
    ".config/rofi/powermenu/type-4/style-3.rasi" = import ./powermenu/style-3.nix;
    ".config/rofi/powermenu/type-4/shared/confirm.rasi" = import ./powermenu/confirm.nix {inherit config;};
  };
}
