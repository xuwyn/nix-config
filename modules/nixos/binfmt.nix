{
  # emulated extra architecture
  modules.nixos.binfmt = {
    config,
    pkgs,
    ...
  }: {
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
}
