{
  host,
  username,
  pkgs,
  lib,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;

  barModule =
    if (vars.barChoice or "") == "noctalia"
    then [./noctalia.nix]
    else if (vars.barChoice or "") == "polybar"
    then [./polybar.nix]
    else [];
in {
  home = {
    username = username;
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/${username}"
      else "/home/${username}";
    stateVersion = "23.11";
    sessionPath = ["$HOME/.local/bin"];
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ../core/nix-conf.nix
      ./apps
      ./nh.nix
      ./cli
      ./python.nix
      ./sops
      ./editors/nixvim.nix # or ./editors/nvf.nix
      ./editors/nano.nix
      ./packages.nix
      ./src-packages.nix
      ./theme/stylix.nix
      ./theme/fonts.nix
    ]
    # Desktop Environments
    ++ lib.optionals (vars.hyprlandEnable or false) ([
        ./hyprland
        ./rofi
        ./scripts
        ./theme/qt.nix
        ./theme/gtk.nix
        ./dotfiles
      ]
      ++ barModule)
    ++ lib.optionals (vars.i3Enable or false) ([
        ./i3
        ./picom.nix
        ./dunst.nix
        ./rofi
        ./scripts
        ./theme/gtk.nix
      ]
      ++ barModule)
    # System/App Toggles
    ++ lib.optional ((vars.fpsLimit or "") != "") ./mangohud.nix
    ++ lib.optional (vars.xdgEnable or false) ./xdg
    ++ lib.optional (vars.quickshellEnable or false) ./quickshell.nix
    ++ lib.optional (vars.virtEnable or false) ./virtmanager.nix
    ++ lib.optional (vars.yaziEnable or false) ./yazi
    ++ lib.optional (vars.thunarEnable or false) ./thunar.nix
    # Editors
    ++ lib.optional (vars.zedEnable or false) ./editors/zed.nix
    ++ lib.optional (vars.helixEnable or false) ./editors/evil-helix.nix
    ++ lib.optional (vars.vscodeEnable or false) ./editors/vscode.nix
    # Terminals
    ++ lib.optional (vars.kittyEnable or false) ./terminals/kitty.nix
    ++ lib.optional (vars.alacrittyEnable or false) ./terminals/alacritty.nix
    ++ lib.optional (vars.weztermEnable or false) ./terminals/wezterm.nix
    ++ lib.optional (vars.ghosttyEnable or false) ./terminals/ghostty.nix
    ++ lib.optional (vars.tmuxEnable or false) ./terminals/tmux.nix;
}
