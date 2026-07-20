{
  modules.homeManager.cli = {
    config,
    lib,
    inputs,
    pkgs,
    ...
  }: let
    cfg = config.homeManager.cli.eyecandy;
    umbrella-fetch = pkgs.rustPlatform.buildRustPackage {
      pname = pkgs.sources.umbrella-fetch.pname;
      version = pkgs.sources.umbrella-fetch.version;
      src = pkgs.sources.umbrella-fetch.src;
      cargoLock.lockFile = "${pkgs.sources.umbrella-fetch.src}/Cargo.lock";
    };
  in {
    options.homeManager.cli.eyecandy = {
      enable = lib.mkEnableOption "Add more eyecandy stuffs for cli";
    };
    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        # --- Eye-candy ---
        onefetch # fastfetch for git repo
        lolcat # Rainbow text
        cowsay # Fun text layout
        cmatrix # Raining text matrix
        asciiquarium-transparent # fish tank
        cbonsai # bonsai tree growing
        pipes # pipes screensaver
        fortune # pseudorandom messages
        taoup # same as fortune
        umbrella-fetch # custom fetch RE theme
      ];
    };
  };
}
