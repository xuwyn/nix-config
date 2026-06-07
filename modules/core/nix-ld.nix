{
  inputs,
  pkgs,
  system,
  ...
}: {
  imports = [inputs.nix-ld.nixosModules.nix-ld];

  programs.nix-ld.dev = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };
}
