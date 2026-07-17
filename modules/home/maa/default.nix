{
  modules.homeManager.maa = {
    config,
    lib,
    pkgs,
    inputs,
    ...
  }: let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    maa-cli = pkgs.rustPlatform.buildRustPackage {
      name = "maa-cli";
      src = inputs.maa-cli;
      cargoHash = "sha256-HQTur+MJLu25auR7+EiFfHoqWOlmDN+EDKI4PJe7wnE=";
      nativeBuildInputs = [pkgs.pkg-config pkgs.makeWrapper];
      buildInputs = [pkgs.openssl];
      doCheck = false;
      postFixup = ''
        wrapProgram $out/bin/maa \
          --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [
          pkgs.stdenv.cc.cc.lib
          pkgs.zlib
        ]}
      '';
    };
  in {
    home = {
      packages = [
        maa-cli
      ];
      file = {
        ".config/maa/profiles".source =
          mkOutOfStoreSymlink
          "${config.home.homeDirectory}/nix-config/modules/home/maa/profiles";
        ".config/maa/tasks".source =
          mkOutOfStoreSymlink
          "${config.home.homeDirectory}/nix-config/modules/home/maa/tasks";
      };
    };
  };
}
