{
  # Git Configuration ( For Pulling Software Repos )
  gitUsername = "wyn";
  gitEmail = "173407133+suquynh@users.noreply.github.com";

  # Set Displau Manager
  # `tui` for Text login (depends on stylixImage)
  # `sddm` for graphical GUI (default)
  # `silent` for silentSDDM
  # SDDM background is set with stylixImage
  displayManager = "silent";

  # Emable/disable bundled applications
  tmuxEnable = false;
  alacrittyEnable = false;
  weztermEnable = false;
  ghosttyEnable = false;
  vscodeEnable = false;
  # Note: This is evil-helix with VIM keybindings by default
  helixEnable = false;
  #OpenRGB
  openrgbEnable = true;

  # Hyprland Settings
  hyprlandEnable = true; # relevant in modules/home/default.nix
  extraMonitorSettings = "
monitor = DP-5,1920x1080@165,0x0,1
monitor = DP-2,1920x1080@165,0x0,1
  ";

  # Bar/Shell Settings
  # Choose between noctalia or waybar
  barChoice = "noctalia";

  # Program Options
  browser = "firefox";

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

  # Available Options:
  # Kitty, ghostty, wezterm, aalacrity
  # Note: kitty, wezterm, alacritty have to be enabled in `variables.nix`
  # Setting it here does not enable it. Kitty is installed by default
  terminal = "kitty"; # Set Default System Terminal

  keyboardLayout = "us";
  keyboardVariant = "";
  consoleKeyMap = "us";

  # For hybrid support (Intel/NVIDIA Prime or AMD/NVIDIA)
  # intelID = "PCI:1:0:0";
  nvidiaID = "PCI:1:0:0";
  amdgpuID = "PCI:15:0:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = true;

  # Enable Thunar GUI File Manager
  # Yazi is alternate File Manager
  thunarEnable = true;

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
