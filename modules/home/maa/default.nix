{
  modules.homeManager.maa = {
    config,
    lib,
    pkgs,
    inputs,
    flake,
    ...
  }: let
    mkOutOfStoreSymlink = path: config.lib.file.mkOutOfStoreSymlink path;
    maa-cli = pkgs.rustPlatform.buildRustPackage {
      pname = pkgs.sources.maa-cli.pname;
      version = pkgs.sources.maa-cli.version;
      src = pkgs.sources.maa-cli.src;
      cargoLock.lockFile = "${pkgs.sources.maa-cli.src}/Cargo.lock";

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
      file =
        if !pkgs.stdenv.hostPlatform.isDarwin
        then {
          ".config/maa/profiles/default.json".source =
            mkOutOfStoreSymlink
            "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/maa/profiles/waydroid.json";
          ".config/maa/tasks".source =
            mkOutOfStoreSymlink
            "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/maa/tasks";
        }
        else {
          "Library/Application Support/com.loong.maa/config/profiles/default.json".source =
            mkOutOfStoreSymlink
            "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/maa/profiles/playcover.json";
          "Library/Application Support/com.loong.maa/config/tasks".source =
            mkOutOfStoreSymlink
            "${config.home.homeDirectory}/${flake.homeRelativePath}/modules/home/maa/tasks";
        };
    };
  };
}
