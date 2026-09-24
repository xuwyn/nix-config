{types, ...}: {
  inputs = {
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    package = {
      type = types.derivation;
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.nix-search-tv;
    };
  };

  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeShellApplication fzf;
  in
    writeShellApplication {
      name = "ns";
      runtimeInputs = [fzf options.package];
      text = builtins.readFile "${options.package.src}/nixpkgs.sh";
    };
}
