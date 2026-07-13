{
  modules.nixos.system = {
    lib,
    config,
    pkgs,
    users,
    ...
  }: let
    cfg = config.nixos.system;
  in {
    options.nixos.system = {
      consoleKeyMap = lib.mkOption {
        type = lib.types.str;
        default = "us";
        description = "Set Console Key Map";
      };
      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "America/Moncton";
        description = "Set Timezone";
      };
    };
    config = {
      system.stateVersion = "23.11"; # Do not change!

      # /etc/nix/nix.conf
      nix = {
        package = pkgs.nix;
        settings = {
          download-buffer-size = 200000000;
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          allowed-users = ["root"] ++ users;
          trusted-users = ["root"] ++ users;
        };
      };

      # Localization
      time.timeZone = cfg.timeZone;
      i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };
      };

      # Console Input
      console.keyMap = cfg.consoleKeyMap;

      # Global environment variables
      environment.variables = {
        NIXOS_OZONE_WL = "1";
      };

      # General services, programs and packages
      services = {
        libinput.enable = true; # Input Handling
        blueman.enable = true; # Bluetooth Support
        fstrim.enable = true; # SSD Optimizer
        gvfs.enable = true; # For Mounting USB & More
      };

      programs = {
        mtr.enable = true; # ping and traceroute

        gnupg.agent = {
          enable = true;
          enableSSHSupport = true;
        };

        dconf.enable = true;
      };

      environment.systemPackages = with pkgs; [
        # --- System Diagnostics & Hardware Probing ---
        inxi # Needs system-wide access to read specs
        mesa-demos # Provides glxinfo/eglinfo used by inxi for GPU tracking
        lm_sensors # Needs root-level access to read motherboard temp sensors
        lshw # Detailed hardware list; won't work properly as a normal user
        pciutils # Inspects physical PCI devices (lspci)
        usbutils # Inspects physical USB buses (lsusb)
        procps # process utilities

        # --- Utilities ---
        killall
        wget
      ];
    };
  };
}
