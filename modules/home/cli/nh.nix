{
  modules.homeManager.cli = {
    pkgs,
    config,
    lib,
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
          extraArgs = "--keep-since 7d --keep 5";
        };
        flake = "${config.home.homeDirectory}/nix-config";
      };

      home.packages = with pkgs; [
        nh
        nix-output-monitor
        nvd
      ];

      home.sessionVariables = {
        NH_FLAKE = "${config.home.homeDirectory}/nix-config";
        NH_HOME_FLAKE = "${config.home.homeDirectory}/nix-config";
      };
    };
  };
}
