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
      packages = with pkgs; [
        tack
        nvfetcher
        inputs.multiverse.packages.${pkgs.stdenv.hostPlatform.system}.mvs
      ];
    };
    programs = {
      home-manager.enable = true;
      nix-index.enable = true;
      nix-index-database.comma.enable = true;
    };
  };
}
