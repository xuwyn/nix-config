{
  platforms = ["linux"];
  module = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.custom.binfmt.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Extra architecture emulation (aarch64-linux) and AppImage support";
    };

    config = lib.mkIf config.custom.binfmt.enable {
      # emulated extra architecture
      boot.binfmt.emulatedSystems = ["aarch64-linux"];

      # Appimage Support
      boot.binfmt.registrations.appimage = {
        wrapInterpreterInShell = false;
        interpreter = "${pkgs.appimage-run}/bin/appimage-run";
        recognitionType = "magic";
        offset = 0;
        mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
        magicOrExtension = ''\x7fELF....AI\x02'';
      };
    };
  };
}
