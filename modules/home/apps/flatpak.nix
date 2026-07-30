{
  modules.homeManager.apps = {
    inputs,
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.apps.flatpak;
  in {
    options.homeManager.apps.flatpak = {
      enable = lib.mkEnableOption "Enable flatpak";
    };

    imports = [inputs.nix-flatpak.homeManagerModules.nix-flatpak];

    config = lib.mkIf cfg.enable {
      home.sessionPath = ["$HOME/.local/share/flatpak/exports/bin"];
      services = {
        flatpak = {
          enable = true;
          packages = [
            # "com.spotify.Client" # Spotify via flatpak to use spicetify-cli
          ];
          update.onActivation = true;
        };
      };
    };
  };
}
