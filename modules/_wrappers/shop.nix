# shop -> comma
{flakeInputs, ...} @ adios: {
  inputs.nixpkgs.from = {parent}: parent.nixpkgs;

  result = adios.promise ({inputs, ...}: let
    pkgs = inputs.nixpkgs.pkgs;
    lib = inputs.nixpkgs.lib;
    system = pkgs.stdenv.hostPlatform.system;
    shop = flakeInputs.nix-shop.packages.${system}.shop;
    nixIndex = flakeInputs.nix-index-database.packages.${system}.nix-index-with-db;
  in
    pkgs.runCommand "shop-comma" {
      nativeBuildInputs = [pkgs.makeWrapper];
      meta.mainProgram = ",";
    } ''
      mkdir -p $out/bin
      makeWrapper ${shop}/bin/shop "$out/bin/," \
        --prefix PATH : ${lib.makeBinPath [nixIndex]}
    '');
}
