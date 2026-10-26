{flakeInputs, ...} @ adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  result = adios.promise ({inputs, ...}: let
    pkgs = inputs.nixpkgs.pkgs;
    lib = pkgs.lib;
    src = flakeInputs.maa-cli;

    maa-cli = pkgs.rustPlatform.buildRustPackage {
      pname = "maa-cli";
      version = (lib.importTOML "${src}/crates/maa-cli/Cargo.toml").package.version;
      inherit src;
      cargoLock.lockFile = "${src}/Cargo.lock";
      cargoBuildFlags = ["--package" "maa-cli"];
      nativeBuildInputs = [pkgs.pkg-config];
      buildInputs = [pkgs.openssl];
      doCheck = false;
      meta.mainProgram = "maa";
    };

    profile =
      if pkgs.stdenv.hostPlatform.isDarwin
      then ./profiles/playcover.json
      else ./profiles/waydroid.json;

    configDir = pkgs.runCommand "maa-config" {} ''
      mkdir -p $out/profiles
      ln -s ${profile} $out/profiles/default.json
      ln -s ${./tasks} $out/tasks
    '';
  in
    pkgs.symlinkJoin {
      name = "maa-cli-wrapped";
      paths = [maa-cli];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/maa \
          ${lib.optionalString pkgs.stdenv.hostPlatform.isLinux
          "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib pkgs.zlib]}"} \
          --set MAA_CONFIG_DIR ${configDir}
      '';
      meta = maa-cli.meta;
    });
}
