{
  flake.modules.nixos.nix-conf = {
    pkgs,
    username,
    ...
  }: {
    nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];

    nix = {
      package = pkgs.nix;
      settings = {
        download-buffer-size = 200000000;
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        allowed-users = ["root" username];
        trusted-users = ["root" username];
      };
    };
  };
}
