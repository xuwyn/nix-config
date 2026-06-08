{
  host,
  username,
  pkgs,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  inherit
    (vars)
    hyprlandEnable
    barChoice
    ghosttyEnable
    tmuxEnable
    weztermEnable
    vscodeEnable
    helixEnable
    zedEnable
    yaziEnable
    ;
  barModule = (
    if barChoice == "noctalia"
    then ./noctalia.nix
    else ./caelestia.nix
  );
in {
  home = {
    username = username;
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/${username}"
      else "/home/${username}";
    stateVersion = "23.11";
    sessionPath = ["$HOME/.local/bin"];
  };
  programs.home-manager.enable = true;

  imports =
    [
      ./cli
      ./python.nix
      ./terminals/kitty.nix
      ./sops
      #./editors/nvf.nix
      ./editors/nixvim.nix
      ./editors/nano.nix
      ./packages.nix
      ./custom-pkgs.nix
    ]
    ++ (
      if hyprlandEnable
      then [
        barModule
        ./apps
        ./dotfiles
        ./hyprland
        ./theme
        ./swaync
        ./rofi
        ./scripts
        ./virtmanager.nix
        ./xdg.nix
      ]
      else []
    )
    ++ (
      if yaziEnable
      then [./yazi]
      else []
    )
    ++ (
      if zedEnable
      then [./editors/zed.nix]
      else []
    )
    ++ (
      if helixEnable
      then [./editors/evil-helix.nix]
      else []
    )
    ++ (
      if vscodeEnable
      then [./editors/vscode.nix]
      else []
    )
    ++ (
      if weztermEnable
      then [./terminals/wezterm.nix]
      else []
    )
    ++ (
      if ghosttyEnable
      then [./terminals/ghostty.nix]
      else []
    )
    ++ (
      if tmuxEnable
      then [./terminals/tmux.nix]
      else []
    );
}
