{
  # emulated extra architecture
  modules.nixos.binfmt = {config, ...}: {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];
  };
}
