{
  targets = ["apricot"];
  module = {
    self,
    system,
    config,
    pkgs,
    lib,
    inputs,
    ...
  }: let
    wm = self.wrapperModules.${system};
    kitty = wm.kitty {fontSize = "10";};
    zeditor = wm.zeditor {};
  in {
    imports = [inputs.mac-app-util.darwinModules.default];

    environment.systemPackages = with wm; [
      kitty
      zeditor
      (cava {})
      (bottom {})
      (btop {})
      (yazi {})
      (spicetify {})
      (maa-cli {})
      (nvf {})
      (sonora {})
      (ff {})
    ];

    # necessary for gui apps launched from Spotlight to load the correct config
    hj.xdg.config.files = {
      "kitty/kitty.conf".source = "${kitty}/kitty/kitty.conf";
      "zed/settings.json".source = zeditor.settingsFile;
    };

    sops = {
      age = {
        keyFile = "${config.hj.directory}/.config/sops/age/keys.txt";
        plugins = [pkgs.age-plugin-yubikey];
      };
      # sops.age.plugins override sops-nix's own PATH instead of appending it
      # leads to hdiutil not found error
      environment.PATH = lib.mkForce "${lib.makeBinPath config.sops.age.plugins}:/usr/bin:/bin:/usr/sbin:/sbin";
    };

    custom = {
      ssh.hosts = {
        puffin = {};
        mango = {};
        capybara = {};
        lettuce = {};
        "puffin.local" = {};
        "mango.local" = {};
        "capybara.local" = {};
        "lettuce.local" = {};
      };

      deploy.controller.enable = true;
    };
  };
}
