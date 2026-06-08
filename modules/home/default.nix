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
    waybarChoice
    weztermEnable
    vscodeEnable
    helixEnable
    ;
  # Select bar module based on barChoice
  barModule = (
    if barChoice == "noctalia"
    then ./noctalia.nix
    else waybarChoice
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
      ./bash.nix
      ./zsh.nix
      ./python.nix
      ./eza.nix
      ./starship.nix
      ./fastfetch
      ./zoxide.nix
      ./tealdeer.nix
      ./terminals/kitty.nix # add this to homebrew if port to mac
      ./yazi
      ./sops
      #./editors/nvf.nix
      ./editors/nixvim.nix
      ./editors/nano.nix
      ./editors/zed.nix
      ./packages.nix
    ]
    ++ (
      if hyprlandEnable
      then [
        # Apps
        ./custom-pkgs.nix
        ./flatpak.nix
        ./spicetify.nix
        ./nixcord.nix
        ./firefox.nix
        ./obs-studio.nix
        # WM
        barModule
        ./dotfiles.nix
        ./hyprland
        ./gtk.nix
        ./qt.nix
        ./xdg.nix
        ./swaync
        ./rofi
        ./scripts
        ./stylix.nix
        ./virtmanager.nix
      ]
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
