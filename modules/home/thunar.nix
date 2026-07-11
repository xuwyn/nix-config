{
  modules.homeManager.thunar = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.thunar;
  in {
    options.homeManager.thunar = {
      terminal = lib.mkOption {
        type = lib.types.enum ["kitty" "alacritty" "foot" "wezterm" "ghostty"];
        default = "kitty";
        description = "Set default terminal for thunar";
      };
    };

    config = let
      openTerminal =
        if cfg.terminal == "foot"
        then "foot -D %f"
        else if cfg.terminal == "kitty"
        then "kitty -d %f"
        else if cfg.terminal == "alacritty"
        then "alacritty --working-directory %f"
        else if cfg.terminal == "wezterm"
        then "wezterm start --cwd %f"
        else if cfg.terminal == "ghostty"
        then "ghostty --working-directory=%f"
        else throw "Unknown terminal type set in thunar.nix!";
    in {
      # Open chosen terminal
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
        <action>
            <icon>utilities-terminal</icon>
            <name>Open Terminal Here</name>
            <submenu></submenu>
            <unique-id>1710575157271461-1</unique-id>
            <command>${openTerminal}</command>
            <description>Open the current directory in ${cfg.terminal}</description>
            <range></range>
            <patterns>*</patterns>
            <startup-notify/>
            <directories/>
        </action>
        </actions>
      '';

      # Set Bookmarks (xdg user-dirs is not enough)
      home.file.".config/gtk-3.0/bookmarks".text = ''
        file://${config.home.homeDirectory}/Downloads Downloads
        file://${config.home.homeDirectory}/Documents Documents
        file://${config.home.homeDirectory}/Pictures Pictures
        file://${config.home.homeDirectory}/Pictures/Screenshots Screenshots
        file://${config.home.homeDirectory}/Music Music
        file://${config.home.homeDirectory}/Videos Videos
      '';
    };
  };
}
