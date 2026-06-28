{
  flake.modules.nixos.services = {
    inputs,
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
    imports = [inputs.nix-ld.nixosModules.nix-ld];
    config = lib.mkIf cfg.enable {
      programs.nix-ld.dev = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc
        ];
      };
    };
  };
}
