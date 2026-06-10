{
  ### SYSTEM HARDWARE & IDENTITY
  # Host-specific user groups (core/user.nix)
  extraUserGroups = [];

  # Hardware IDs (Set via `lspci | grep -E "VGA|3D"`)
  # intelID = "PCI:1:0:0";
  nvidiaID = "PCI:1:0:0";
  amdgpuID = "PCI:15:0:0";

  # Network Host ID (Required for ZFS setups)
  hostId = "5ab03f50";

  # Keyboard & Console Locale
  keyboardLayout = "us";
  keyboardVariant = "";
  consoleKeyMap = "us";

  ### SYSTEM FEATURES & SERVICES
  # Core System Daemons & Utilities
  xserverEnable = true;
  printEnable = true;
  gsrEnable = true; # gpu-screen-recorder
  devToolsEnable = true; # cachix, nix-ld
  openrgbEnable = true;

  # Network Shares & Syncing
  nfsEnable = true;
  syncthingEnable = false;
  virtEnable = false;

  # Additional Applications
  flatpakEnable = true;
  steamEnable = true;
  thunarEnable = true;

  ### DESKTOP ENVIRONMENT & GRAPHICS
  # Login Screen ("tui" for text login, "sddm", or "silent")
  displayManager = "silent";

  # Window Manager
  hyprlandEnable = true;
  extraMonitorSettings = "
monitor = DP-5,1920x1080@165,0x0,1
monitor = DP-2,1920x1080@165,0x0,1
  ";

  # Shell Panels & Bars
  barChoice = "noctalia";
  barThemeEnable = true; # check home stylix
  quickshellEnable = false;

  # System Theming (Stylix)
  systemThemeEnable = true;
  stylixImage = ../../wallpapers/interlude_MDxBA_1.png;

  # Active Hyprland Animation Style
  animChoice = ../../modules/home/hyprland/animations/animations-ml4w-classic.nix;

  ### USER ENVIRONMENT & APPLICATIONS
  # Git Identity
  gitUsername = "wyn";
  gitEmail = "173407133+suquynh@users.noreply.github.com";

  # Shell Settings (core/user.nix)
  # (Options: "zsh", "bash")
  shell = "zsh";

  # Default Applications
  terminal = "kitty";
  browser = "firefox";

  # Alternative Terminal Toggles
  tmuxEnable = false;
  alacrittyEnable = false;
  weztermEnable = false;
  ghosttyEnable = false;

  # Development Text Editors
  vscodeEnable = false;
  helixEnable = false;
  zedEnable = true;

  # File Managers
  yaziEnable = true;

  # Host-Level App Defaults (Home Manager xdg.mimeApps)
  # mimeDefaultApps = {
  #   "application/pdf" = ["okular.desktop"];
  #   "application/x-pdf" = ["okular.desktop"];
  #   "x-scheme-handler/http"  = ["google-chrome.desktop"]; # or firefox.desktop
  #   "x-scheme-handler/https" = ["google-chrome.desktop"];
  #   "text/html"              = ["google-chrome.desktop"];
  #   "inode/directory" = ["thunar.desktop"];
  #   "text/plain"      = ["nvim.desktop"];
  # };
}
