{
  ### DESKTOP ENVIRONMENT
  stylixImage = ../../wallpapers/voyager.png;
  barChoice = "polybar";
  barThemeEnable = false;
  i3Enable = true;
  hyprlandEnable = false;

  ### PERIPHERALS
  # To get current monitors on i3/X11:
  #$ xrandr --query
  #$ polybar --list-monitors # if using polybar
  monitors = [
    {
      name = "DP-2";
      refreshRate = "164.96";
      workspaces = ["1" "2" "3" "4" "5"];
    }
  ];

  ### USER ENVIRONMENT & APPLICATIONS
  # Git Identity
  gitUsername = "wyn";
  gitEmail = "173407133+suquynh@users.noreply.github.com";

  # Default apps
  terminal = "kitty";
  browser = "firefox";

  # Alternative Terminal Toggles
  kittyEnable = true;
  tmuxEnable = false;
  alacrittyEnable = false;
  weztermEnable = false;
  ghosttyEnable = false;

  # Extra Text Editors
  vscodeEnable = false;
  helixEnable = false;
  zedEnable = true;

  # File Managers
  yaziEnable = true;
  thunarEnable = true;
}
