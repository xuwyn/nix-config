{
  modules.nixos.desktop = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.nixos.desktop.thunar;
  in {
    options.nixos.desktop.thunar = {
      enable = lib.mkEnableOption "Enable Thunar";
      terminal = lib.mkOption {
        type = lib.types.enum ["kitty" "alacritty" "foot" "wezterm" "ghostty"];
        default = config.nixos.desktop.terminal; # point at wherever your terminal choice lives now
        description = "Set default terminal for thunar";
      };
    };

    config = lib.mkIf cfg.enable {
      programs.thunar = {
        enable = true;
        plugins = [
          pkgs.thunar-archive-plugin
          pkgs.thunar-volman
        ];
      };
      environment.systemPackages = with pkgs; [
        ffmpegthumbnailer # Need For Video / Image Preview
      ];

      # Open chosen terminal
      hj.xdg.config.files."Thunar/uca.xml".text = let
        openTerminal =
          {
            foot = "foot -D %f";
            kitty = "kitty -d %f";
            alacritty = "alacritty --working-directory %f";
            wezterm = "wezterm start --cwd %f";
            ghostty = "ghostty --working-directory=%f";
          }.${
            cfg.terminal
          };
      in ''
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
      hj.xdg.config.files."gtk-3.0/bookmarks".text = ''
        file://${config.hj.directory}/Downloads Downloads
        file://${config.hj.directory}/Documents Documents
        file://${config.hj.directory}/Pictures Pictures
        file://${config.hj.directory}/Pictures/Screenshots Screenshots
        file://${config.hj.directory}/Music Music
        file://${config.hj.directory}/Videos Videos
      '';
    };
  };
}
