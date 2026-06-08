{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "wyn";
  gitEmail = "173407133+suquynh@users.noreply.github.com";

  # host-specific user groups (core/user.nix)
  extraUserGroups = [];

  # Keyboard
  keyboardLayout = "us";
  keyboardVariant = "";
  consoleKeyMap = "us";

  # Set GPU addresses `lspci | grep -E "VGA|3D"`
  # intelID = "PCI:1:0:0";
  nvidiaID = "PCI:1:0:0";
  amdgpuID = "PCI:15:0:0";

  # Set Display Manager
  # `tui` for Text login (default)
  # `sddm` for ZaneyOS SDDM
  # `silent` for silentSDDM
  displayManager = "silent";

  # Terminal Options
  # default = kitty
  tmuxEnable = false;
  alacrittyEnable = false;
  weztermEnable = false;
  ghosttyEnable = false;

  # Set Default System Terminal
  terminal = "kitty";

  # Set default shell
  # default = bash
  # options = ["zsh" "bash"]
  shell = "zsh";

  # Editor Options
  # default = [vi nano]
  vscodeEnable = false;
  helixEnable = false;
  zedEnable = true;

  # File Manager Options
  thunarEnable = true;
  yaziEnable = true;

  # Set Default Browser
  browser = "firefox";

  # Networking
  nfsEnable = true;
  syncthingEnable = false;
  virtEnable = false;

  # System Utilities
  systemThemeEnable = true;
  printEnable = true;
  gsrEnable = true;
  xserverEnable = true;
  devToolsEnable = true;

  # Extra Software
  openrgbEnable = true;
  flatpakEnable = true;
  steamEnable = true;

  # Host-level default applications (picked up by Home Manager xdg.mimeApps)
  # Uncomment and adjust the .desktop IDs to set per-host defaults.
  # mimeDefaultApps = {
  #   # PDFs
  #   "application/pdf" = ["okular.desktop"];
  #   "application/x-pdf" = ["okular.desktop"];
  #   # Web browser
  #   "x-scheme-handler/http"  = ["google-chrome.desktop"];  # or brave-browser.desktop, firefox.desktop
  #   "x-scheme-handler/https" = ["google-chrome.desktop"];
  #   "text/html"              = ["google-chrome.desktop"];
  #   # Files
  #   "inode/directory" = ["thunar.desktop"];      # file manager
  #   "text/plain"      = ["nvim.desktop"];        # or code.desktop
  # };

  # Desktop/WM Settings
  hyprlandEnable = true;
  extraMonitorSettings = "
monitor = DP-5,1920x1080@165,0x0,1
monitor = DP-2,1920x1080@165,0x0,1
  ";

  # Bar/Shell Settings
  barChoice = "noctalia";
  quickshellEnable = false;

  # Set Stylix Image (App themes based on background)
  stylixImage = ../../wallpapers/interlude_109.png;

  # Set Animation style
  # Available options are:
  #animChoice = ../../modules/home/hyprland/animations/animations-def.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-end4.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-end4-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-end-slide.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-dynamic.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-moving.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-hyde-optimized.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-mahaveer-me-1.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-mahaveer-me-2.nix;
  animChoice = ../../modules/home/hyprland/animations/animations-ml4w-classic.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-ml4w-fast.nix;
  #animChoice = ../../modules/home/hyprland/animations/animations-ml4w-high.nix;

  # Set network hostId if required (needed for zfs)
  # Otherwise leave as-is
  hostId = "5ab03f50";
}
