{
  pkgs,
  lib,
  host,
  ...
}: let
  vars = import ../../hosts/${host}/variables.nix;
  hyprlandEnable = vars.hyprlandEnable or false;
in {
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    dconf.enable = true;
    seahorse.enable = true;
    fuse.userAllowOther = true;
    mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    hyprland = lib.mkIf hyprlandEnable {
      enable = true; # set this so desktop file is created
      withUWSM = false;
    };
    hyprlock = lib.mkIf hyprlandEnable {
      enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = ["openssl-1.1.1w"];

  environment.systemPackages = with pkgs; [
    # --- Login Managers ---
    tuigreet # login manager runs as a root daemon
    cmatrix # for fancy tui login
    uwsm # Wayland session manager, hooks into system systemd/PAM

    # --- Hardware, Power, & Drivers ---
    brightnessctl # Needs hardware permissions to alter laptop backlight
    ddcutil # Needs direct access to monitor I2C buses for brightness
    power-profiles-daemon # System-level power management daemon
    upower # System daemon for battery tracking
    v4l-utils # Video4Linux utils; handles kernel-level webcam/OBS loops

    # --- System Diagnostics & Hardware Probing ---
    inxi # Needs system-wide access to read specs
    mesa-demos # Provides glxinfo/eglinfo used by inxi for GPU tracking
    lm_sensors # Needs root-level access to read motherboard temp sensors
    lshw # Detailed hardware list; won't work properly as a normal user
    pciutils # Inspects physical PCI devices (lspci)
    usbutils # Inspects physical USB buses (lsusb)

    # --- Backup Utilities ---
    killall
    wget
  ];
}
