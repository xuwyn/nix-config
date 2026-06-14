{
  host,
  username,
  pkgs,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  hyprlandEnable = vars.hyprlandEnable or false;
  barChoice = vars.barChoice or "";
  alacrittyEnable = vars.alacrittyEnable or false;
  ghosttyEnable = vars.ghosttyEnable or false;
  tmuxEnable = vars.tmuxEnable or false;
  kittyEnable = vars.kittyEnable or false;
  weztermEnable = vars.weztermEnable or false;
  vscodeEnable = vars.vscodeEnable or false;
  helixEnable = vars.helixEnable or false;
  zedEnable = vars.zedEnable or false;
  yaziEnable = vars.yaziEnable or false;
  virtEnable = vars.virtEnable or false;

  barModule = (
    if barChoice == "noctalia"
    then [./noctalia.nix]
    else []
  );
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

  imports =
    [
      ./cli
      ./python.nix
      ./sops
      #./editors/nvf.nix
      ./editors/nixvim.nix
      ./editors/nano.nix
      ./packages.nix
      ./src-packages.nix
      ./theme/stylix.nix
      ./theme/fonts.nix
    ]
    ++ (
      if hyprlandEnable
      then
        [
          ./apps
          ./dotfiles
          ./hyprland
          ./theme/qt.nix
          ./theme/gtk.nix
          ./rofi
          ./scripts
          ./xdg.nix
        ]
        ++ barModule
      else []
    )
    ++ (
      if virtEnable
      then [./virtmanager.nix]
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
      if kittyEnable
      then [./terminals/kitty.nix]
      else []
    )
    ++ (
      if alacrittyEnable
      then [./terminals/alacritty.nix]
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
