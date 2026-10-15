{
  tags = ["desktop"];
  platforms = ["linux"];
  module = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.custom.thunar;

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
  in {
    options.custom.thunar.terminal = lib.mkOption {
      type = lib.types.enum ["kitty" "alacritty" "foot" "wezterm" "ghostty"];
      default = config.custom.desktop.terminal;
      description = "Set default terminal for thunar";
    };

    config = lib.mkMerge [
      {
        programs.thunar = {
          enable = lib.mkDefault true;
          plugins = [
            pkgs.thunar-archive-plugin
            pkgs.thunar-volman
          ];
        };
      }

      (lib.mkIf config.programs.thunar.enable {
        environment.systemPackages = with pkgs; [
          ffmpegthumbnailer # Need For Video / Image Preview
        ];

        # Open chosen terminal
        hj.xdg.config.files."Thunar/uca.xml".text = ''
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
      })
    ];
  };
}
