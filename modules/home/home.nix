{inputs, ...}: {
  modules.homeManager.home = {
    username,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-index-database.homeModules.default];

    home = {
      username = username;
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/${username}"
        else "/home/${username}";
      stateVersion = "23.11"; # Do not change!
      sessionPath = ["$HOME/.local/bin"];
    };

    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    nix = {
      package = pkgs.nix;
      settings = {
        accept-flake-config = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        allowed-users = ["root" username];
        trusted-users = ["root" username];
      };
    };

    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
