{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./portal.nix
    ./mimeapps.nix
  ];

  home.packages = with pkgs; [
    xdg-user-dirs
    xdg-user-dirs-gtk
  ];

  xdg = {
    enable = true;

    # Home Directory Defaults
    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      download = "${config.home.homeDirectory}/Downloads";
      documents = "${config.home.homeDirectory}/Documents";
      pictures = "${config.home.homeDirectory}/Pictures";
      music = "${config.home.homeDirectory}/Music";
      videos = "${config.home.homeDirectory}/Videos";

      # Add custom directories if needed
      extraConfig = {
        SCREENSHOTS = "${config.home.homeDirectory}/Pictures/Screenshots";
      };
    };
  };
}
