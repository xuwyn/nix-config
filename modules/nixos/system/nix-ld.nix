{
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    ...
  }: {
    options.custom.nix-ld.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "dynamic libraries for fhs stuffs";
    };

    config = lib.mkIf config.custom.nix-ld.enable {
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
