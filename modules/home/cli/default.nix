{config, ...}: let
  inherit (config.flake.modules) homeManager;
in {
  flake.modules.homeManager.cli = {
    imports = with homeManager; [
      fastfetch
      bash
      bat
      bottom
      btop
      cava
      eza
      fzf
      git
      htop
      starship
      tealdeer
      zoxide
      zsh
    ];
  };
}
