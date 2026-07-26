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
          version = "610.43.03"; # CHANGE THIS AFTER DRIVER UPDATE!!!
          sha256 = "sha256-ReLUwTSiPDXlDyU6SqY+fl6NF+PRhdSgfIpY6WEu05I=";
        };
      };
    };
  };
}
