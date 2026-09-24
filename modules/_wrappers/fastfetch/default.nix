_: {
  options.settings.defaultFunc = {inputs}: let
    logos = import ./logos.nix inputs.nixpkgs.pkgs;
  in
    import ./profiles/mini.nix logos.nixos;

  mutations."/zsh".extraPackages = {options}: [(options {})];
}
