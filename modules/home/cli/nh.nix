{
  modules.homeManager.cli = {
    pkgs,
    config,
    lib,
    flake,
    ...
  }: let
    cfg = config.homeManager.cli.nh;
  in {
    options.homeManager.cli.nh = {
      enable = lib.mkEnableOption "Enable nh";
    };

    config = lib.mkIf cfg.enable {
      programs.nh = {
        enable = true;
        clean = {
          enable = true;
          extraArgs = "--keep-since 7d --keep 1 --optimise";
        };
        flake = "${config.home.homeDirectory}/${flake.homeRelativePath}";
      };

      home.packages = with pkgs; [
        nix-output-monitor
        nvd
      ];

      # The above should have worked, but just in case
      home.sessionVariables = {
        NH_FLAKE = "${config.home.homeDirectory}/${flake.homeRelativePath}";
        NH_HOME_FLAKE = "${config.home.homeDirectory}/${flake.homeRelativePath}";
      };
    };
  };
}
