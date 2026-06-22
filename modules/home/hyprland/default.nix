{
  host,
  lib,
  ...
}: let
  vars = import ../../../hosts/${host}/variables.nix;
  animChoice = vars.animChoice or ./animations/animations-ml4w-classic.nix;
  hypridleEnable = vars.hypridleEnable or false;
  hyprlockEnable = vars.hyprlockEnable or false;
in {
  imports =
    [
      animChoice
      ./binds.nix
      ./env.nix
      ./exec-once.nix
      ./hypridle.nix
      ./hyprland.nix
      ./hyprlock.nix
      ./windowrules.nix
    ]
    ++ lib.optional hypridleEnable ./hypridle.nix
    ++ lib.optional hyprlockEnable ./hyprlock.nix;
}
