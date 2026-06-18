{
  pkgs,
  config,
  ...
}: {
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "${config.home.homeDirectory}/nixos";
    # osFlake = "${config.home.homeDirectory}/nixos";
    # homeFlake = "${config.home.homeDirectory}/nixos";
  };

  home.packages = with pkgs; [
    nh
    nix-output-monitor
    nvd
  ];

  home.sessionVariables = {
    NH_FLAKE = "${config.home.homeDirectory}/nixos";
    NH_HOME_FLAKE = "${config.home.homeDirectory}/nixos";
  };
}
