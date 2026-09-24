{types, ...}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    username = {
      type = types.string;
      description = "Username on this host";
    };
    flakePath = {
      type = types.string;
      default = "nix-config";
      description = "Path to the flake relative to $HOME";
    };
    package = {
      type = types.derivation;
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.nh;
    };
  };

  impl = {
    options,
    inputs,
  }: let
    isDarwin = inputs.nixpkgs.pkgs.stdenv.hostPlatform.isDarwin;
    homeDirectory =
      if isDarwin
      then "/Users/${options.username}"
      else "/home/${options.username}";
  in
    inputs.mkWrapper {
      inherit (options) package;
      environment.NH_FLAKE = "${homeDirectory}/${options.flakePath}";
    };
}
