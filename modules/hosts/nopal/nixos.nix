{
  targets = ["nopal"];
  module = {
    self,
    pkgs,
    config,
    lib,
    system,
    inputs,
    ...
  }: let
    wm = self.wrapperModules.${system};
  in {
    imports = [./_hardware-configuration.nix];

    boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
    boot.blacklistedKernelModules = ["b43" "bcma" "ssb"];
    nixpkgs.config.permittedInsecurePackages = ["broadcom-sta-6.30.223.271-63-${config.boot.kernelPackages.kernel.version}"];

    environment.systemPackages = with wm; [
      (ff {})
      (bottom {})
      (firefox {})
      (nvf {})
      (cava {noctaliaThemeEnabled = true;})
      (btop {noctaliaThemeEnabled = true;})
      (kitty {noctaliaThemeEnabled = true;})
      (yazi {noctaliaThemeEnabled = true;})
    ];

    sops.age = {
      keyFile = "/persist${config.hj.directory}/.config/sops/age/keys.txt";
      plugins = [pkgs.age-plugin-yubikey];
    };

    programs = {
      nixcord.enable = false;
      steam.enable = false;
    };

    services.hardware.openrgb.enable = false;
    virtualisation.waydroid.enable = false;

    custom = {
      binfmt.enable = false;
      nix-ld.enable = false;
      printing.enable = false;

      # need declaration
      preservation.users.wyn = {};

      ssh.hosts = {
        apricot = {};
        puffin = {};
        mango = {};
        "apricot.local" = {};
        "puffin.local" = {};
        "mango.local" = {};
      };

      displayManager.mode = "tui";

      desktop = {
        monitors = [
          {
            name = "eDP-1";
            width = 1440;
            height = 900;
            x = 0;
            y = 0;
            refresh = 60;
          }
        ];

        startupCommands = [
          "fcitx5 -d -r"
        ];
      };
    };
  };
}
