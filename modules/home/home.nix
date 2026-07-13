{inputs, ...}: {
  modules.homeManager.home = {
    username,
    pkgs,
    config,
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
      sessionVariables = {
        TACK_NIX_CONF_TOKENS = "1";
      };
      packages = [pkgs.tack];
    };

    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;

    nix = {
      package = pkgs.nix;
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        allowed-users = ["root" username];
        trusted-users = ["root" username];
      };
      extraOptions = ''
        !include ${config.sops.templates."nix-access-tokens.conf".path}
      '';
    };

    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
