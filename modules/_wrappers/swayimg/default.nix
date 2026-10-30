{types, ...} @ adios: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    package = {
      type = types.derivation;
      default = adios.promise ({inputs}: inputs.nixpkgs.pkgs.swayimg);
    };

    initLuaFile = {
      type = types.pathLike;
      default = ./init.lua;
    };

    extraPackages = {
      type = types.listOf types.derivation;
      default = adios.promise ({inputs}: with inputs.nixpkgs.pkgs; [wl-clipboard]);
      description = "Packages added to the wrapper's PATH.";
    };
  };

  inputs.mkWrapper.options = adios.promise (
    {
      options,
      inputs,
    }: {
      inherit (options) package;
      flags = [
        "--config"
        "${options.initLuaFile}"
      ];
      wrapperArgs = ''
        --prefix PATH : ${inputs.nixpkgs.lib.makeBinPath options.extraPackages}
      '';
    }
  );

  result = adios.promise ({results}: results.mkWrapper);
}
