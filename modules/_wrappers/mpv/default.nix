{types, ...} @ adios: {
  options = {
    scripts.default = adios.promise ({inputs, ...}: let
      inherit (inputs.nixpkgs) pkgs;
    in
      with pkgs.mpvScripts; [
        autoload
        modernz
        thumbfast
      ]);
    configFile.default = ./modernz.conf;
  };
}
