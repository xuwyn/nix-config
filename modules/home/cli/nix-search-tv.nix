{
  modules.homeManager.cli = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.cli.nix-search-tv;

    # shell abbr. and fzf integration
    ns-script = pkgs.writeShellApplication {
      name = "ns";
      runtimeInputs = with pkgs; [
        fzf
        nix-search-tv
      ];
      text = builtins.readFile "${pkgs.nix-search-tv.src}/nixpkgs.sh";
    };
  in {
    options.homeManager.cli.nix-search-tv = {
      enable = lib.mkEnableOption "Enable nix-search-tv with TV and fzf";
    };
    config = lib.mkIf cfg.enable {
      # tv integration
      programs.nix-search-tv = {
        enable = true;
        enableTelevisionIntegration = true;
      };

      # add to user path
      home.packages = [ns-script];
    };
  };
}
