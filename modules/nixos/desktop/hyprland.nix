{
  flake.modules.nixos.hyprland = {pkgs, ...}: {
    programs = {
      dconf.enable = true;
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
