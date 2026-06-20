{
  pkgs,
  username,
  ...
}: {
  nix = {
    package = pkgs.nix;
    settings = {
      download-buffer-size = 200000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      allowed-users = ["${username}"];
      trusted-users = ["${username}"];
    };
  };
}
