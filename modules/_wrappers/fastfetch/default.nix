adios: {
  options.settings.default = adios.promise ({inputs}: let
    logos = import ./logos.nix inputs.nixpkgs.pkgs;
  in
    import ./profiles/mini.nix logos.nixos);

  mutations."/zsh".extraPackages = adios.promise ({options}: [(options {})]);
}
