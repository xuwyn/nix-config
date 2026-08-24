{
  modules.nixos.rpi5 = {
    lib,
    config,
    pkgs,
    nixos-raspberrypi,
    ...
  }: {
    # Read: https://github.com/nvmd/nixos-raspberrypi/blob/develop/README.md
    imports = with nixos-raspberrypi.nixosModules; [
      nixos-raspberrypi.lib.inject-overlays-global
      nixpkgs-rpi
      trusted-nix-caches
      usb-gadget-ethernet
      raspberry-pi-5.base
      raspberry-pi-5.bluetooth
      raspberry-pi-5.page-size-16k
      raspberry-pi-5.display-vc4 # "regular" display connected
      # raspberry-pi-5.display-rp1 # for RP1-connected (DPI/composite/MIPI DSI) display
    ];

    # To match with nvmd/nixos-raspberrypi image
    boot.loader.raspberry-pi.bootloader = "kernel";
    boot.tmp.useTmpfs = true;
    networking.networkmanager.enable = false;
    networking.wireless.iwd = {
      enable = true;
      settings = {
        Network = {
          EnableIPv6 = true;
          RoutePriorityOffset = 300;
        };
        General.EnableNetworkConfiguration = true;
        Settings.AutoConnect = true;
      };
    };

    # Do not take down the network for too long when upgrading,
    # This also prevents failures of services that are restarted instead of stopped.
    # It will use `systemctl restart` rather than stopping it with `systemctl stop` followed by a delayed `systemctl start`.
    systemd.services = {
      systemd-networkd.stopIfChanged = false;
      systemd-resolved.stopIfChanged = false;
    };

    # Read: https://github.com/nvmd/nixos-raspberrypi-demo/blob/main/pi5-configtxt.nix
    hardware.raspberry-pi.config = {
      all = {
        # [all] conditional filter, https://www.raspberrypi.com/documentation/computers/config_txt.html#conditional-filters

        options = {
          # https://www.raspberrypi.com/documentation/computers/config_txt.html#enable_uart
          # in conjunction with `console=serial0,115200` in kernel command line (`cmdline.txt`)
          # creates a serial console, accessible using GPIOs 14 and 15 (pins
          #  8 and 10 on the 40-pin header)
          enable_uart = {
            enable = true;
            value = true;
          };
          # https://www.raspberrypi.com/documentation/computers/config_txt.html#uart_2ndstage
          # enable debug logging to the UART, also automatically enables
          # UART logging in `start.elf`
          uart_2ndstage = {
            enable = true;
            value = true;
          };
        };

        # Base DTB parameters
        # https://github.com/raspberrypi/linux/blob/a1d3defcca200077e1e382fe049ca613d16efd2b/arch/arm/boot/dts/overlays/README#L132
        base-dt-params = {
          # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#enable-pcie
          pciex1 = {
            enable = true;
            value = "on";
          };
          # PCIe Gen 3.0
          # https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#pcie-gen-3-0
          pciex1_gen = {
            enable = true;
            value = "3";
          };
        };
      };
    };
  };
}
