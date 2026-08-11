{
  modules.homeManager.home = {
    inputs,
    username,
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [inputs.nix-index-database.homeModules.default];

    home = {
      username = username;
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/${username}"
        else "/home/${username}";
      stateVersion = "26.05";
      sessionPath = ["$HOME/.local/bin"];
      sessionVariables = {
        TACK_NIX_CONF_TOKENS = "1";
      };
      packages = [
        inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.nvfetcher
      ];
    };

    programs.home-manager.enable = true;

    programs = {
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
