{
  flake.modules.nixos.boot = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: let
    cfg = config.nixos.boot;
  in {
    options.nixos.boot = {
      cachyOSKernel = {
        enable = lib.mkEnableOption "Use CachyOS kernel";
        package = lib.mkOption {
          type = lib.types.raw;
          default = pkgs.cachyosKernels.linux-cachyos-latest;
          description = "Choose specific cachyos kernel version";
        };
      };
    };
    config = {
      boot = {
        kernelPackages =
          if cfg.cachyOSKernel.enable
          then cfg.cachyOSKernel.package
          else pkgs.linuxPackages_latest;
        kernelModules = ["v4l2loopback"];
        extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
        kernel.sysctl = {"vm.max_map_count" = 2147483642;};
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;

        # Appimage Support
        binfmt.registrations.appimage = {
          wrapInterpreterInShell = false;
          interpreter = "${pkgs.appimage-run}/bin/appimage-run";
          recognitionType = "magic";
          offset = 0;
          mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
          magicOrExtension = ''\x7fELF....AI\x02'';
        };
        plymouth.enable = true;
      };
    };
  };
}
