{
  flake.modules.homeManager.apps = {
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

          # List the Flatpak applications you want to install
          # Use the official Flatpak application ID (e.g., from flathub.org)
          # Examples:
          packages = [
            #"com.github.tchx84.Flatseal" #Manage flatpak permissions - should always have this
            #"com.rtosta.zapzap"              # WhatsApp client
            #"io.github.flattool.Warehouse"   # Manage flatpaks, clean data, remove flatpaks and deps
            #"it.mijorus.gearlever" # Manage and support AppImages
            #"io.github.freedoom.Phase1"      #  Classic Doom FPS 1
            #"io.github.freedoom.Phase2"      #  Classic Doom FPS 2
            #"io.github.dvlv.boxbuddyrs"      #  Manage distroboxes
            #"de.schmidhuberj.tubefeeder"     #watch YT videos

            # Add other Flatpak IDs here, e.g., "org.mozilla.firefox"
            # "com.spotify.Client" # Spotify via flatpak to use spicetify-cli
          ];

          # Optional: Automatically update Flatpaks when you run nixos-rebuild swit ch
          update.onActivation = true;
        };
      };
    };
  };
}
