{
  flake.modules.nixos.hyprland = {pkgs, ...}: {
    programs = {
      seahorse.enable = true;
      localsend.enable = true;

      hyprland = {
        enable = true; # set this so desktop file is created
        withUWSM = false;
      };

      # hyprlock.enable = true;
    };
  };
}
