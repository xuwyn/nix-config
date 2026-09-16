{
  modules.nixos.boot = {
    pkgs,
    config,
    lib,
    inputs,
    ...
  }: {
    imports = [inputs.stylix.nixosModules.stylix];

    boot = {
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      kernel.sysctl."vm.max_map_count" = 2147483642;
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

      # splash screen
      plymouth.enable = lib.mkDefault true;
    };

    # stylix just for plymouth
    stylix = {
      enable = config.boot.plymouth.enable;
      autoEnable = false;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      targets.plymouth.enable = true;
    };
  };
}
