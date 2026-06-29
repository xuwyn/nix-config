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
          version = "610.43.02"; # CHANGE THIS AFTER DRIVER UPDATE!!!
          sha256 = "sha256-MDSgVLtM33dS/43CclZMsQVROAS/9TU4lFkBsWyndGM=";
        };
      };
    };
  };
}
