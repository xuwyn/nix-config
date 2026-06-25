{
  pkgs,
  config,
  ...
}: let
  inherit (config.homeManager.i3) background;
in {
  xsession.windowManager.i3 = {
    config = {
      startup = [
        {
          command = "${pkgs.dex}/bin/dex --autostart --environment i3";
          notification = false;
          always = false;
        }
        {
          command = "lxpolkit";
          always = false;
          notification = false;
        }
        {
          command = "autotiling";
          always = false;
          notification = false;
        }
        {
          command = "natural-scroll";
          always = true;
          notification = false;
        }
        {
          command = "tap-to-click";
          always = true;
          notification = false;
        }
        {
          command = "set-refresh-rates";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart dunst.service";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart picom.service";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar.service";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.haskellPackages.greenclip}/bin/greenclip daemon &";
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.feh}/bin/feh --bg-scale ${background}";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
