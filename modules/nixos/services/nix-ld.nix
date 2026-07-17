{
  modules.nixos.services = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.services.nix-ld;
  in {
    options.nixos.services.nix-ld = {
      enable = lib.mkEnableOption "Enable nix-ld";
    };
    config = lib.mkIf cfg.enable {
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
          stdenv.cc.cc.lib
          zlib
        ];
      };
    };
  };
}
