{
  pkgs,
  config,
  ...
}: let
  background = config.homeManager.i3.background;
in {
  home.packages =
    [
      (import ./media-status.nix {inherit pkgs;})
      (import ./polybar-launcher.nix {inherit pkgs;})
      (import ./tap-to-click.nix {inherit pkgs;})
      (import ./natural-scroll.nix {inherit pkgs;})
      (import ./set-refresh-rates.nix {inherit pkgs;})
      (import ./i3-lock.nix {inherit pkgs background config;})
    ];
}
