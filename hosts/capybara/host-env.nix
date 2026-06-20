{...}: {
  # Graphic integration
  nixpkgs.config.nvidia.acceptLicense = true;
  targets = {
    genericLinux = {
      enable = true;
      gpu = {
        enable = true;
        nvidia = {
          enable = true;
          version = "595.71.05"; # CHANGE THIS AFTER DRIVER UPDATE!!!!!
          # donot delete, dummy hash for nix to fetch the right one
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      };
    };
  };
}
