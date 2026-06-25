{
  pkgs,
  config,
  username,
  ...
}: {
  home.packages = [
    (import ./rofi-launcher.nix {inherit pkgs;})
    (import ./web-search.nix {inherit pkgs;})
    (import ./powermenu {inherit pkgs username;})
  ];

  # Helper files
  home.file = {
    ".config/rofi/powermenu/type-4/style-3.rasi" = import ./powermenu/style-3.nix;
    ".config/rofi/powermenu/type-4/shared/confirm.rasi" = import ./powermenu/confirm.nix {inherit config;};
  };
}
