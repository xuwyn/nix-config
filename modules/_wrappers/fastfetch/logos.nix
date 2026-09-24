pkgs: let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  frieren = let
    settings =
      if isDarwin
      then {
        type = "kitty-icat";
        padding = {
          top = 0;
          left = 0;
        };
      }
      else {
        type = "kitty";
        padding = {
          top = 1;
          left = 0;
        };
      };
  in
    settings
    // {
      source = ./logos/frieren.png;
      height = 20;
      width = 26;
    };

  onlooker = let
    settings =
      if isDarwin
      then {
        height = 26;
        width = 20;
        padding = {
          top = 2;
          left = 0;
        };
      }
      else {
        height = 40;
        width = 30;
        padding = {
          top = 1;
          left = 0;
        };
      };
  in
    settings
    // {
      source = ./logos/onlooker.gif;
      type = "kitty-icat";
    };

  nixos = {
    source = ./logos/nixos.txt;
    padding = {
      top = 3;
      left = 0;
    };
  };
}
