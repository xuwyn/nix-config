{...} @ adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  result = adios.promise ({inputs, ...}: let
    pkgs = inputs.nixpkgs.pkgs;
    lib = pkgs.lib;

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
      paths = [pkgs.maa-cli];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/maa \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib pkgs.zlib]} \
          --set MAA_CONFIG_DIR ${configDir}
      '';
      meta = pkgs.maa-cli.meta // {mainProgram = "maa";};
    });
}
