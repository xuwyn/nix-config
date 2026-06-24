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
      cachyOSKernel.enable = lib.mkEnableOption "Use CachyOS kernel";
    };
    # duplicate with steam imports
    # imports = [inputs.chaotic.nixosModules.default];

    config = {
      boot = {
        kernelPackages =
          if cfg.cachyOSKernel.enable
          then pkgs.linuxPackages_cachyos
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
