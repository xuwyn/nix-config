{
  flake.modules.nixos.nix-ld = {
    inputs,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-ld.nixosModules.nix-ld];

    programs.nix-ld.dev = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
      ];
    };
  };
}
