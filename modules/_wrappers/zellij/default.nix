{
  types,
  username,
  ...
} @ adios: {
  options = {
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };

    theme = {
      type = types.string;
      default = adios.promise (
        {options}:
          if options.noctaliaThemeEnabled
          then "noctalia"
          else "catppuccin-mocha"
      );
      description = "Theme name written into config.kdl";
    };

    configContents.default = adios.promise (
      {options}:
        ''
          theme "${options.theme}"
          ${
            if options.noctaliaThemeEnabled
            then ''theme_dir "/home/${username}/.config/zellij/themes"''
            else ""
          }
        ''
        + builtins.readFile ./config.kdl
    );

    layoutsContents.default = {
      custom = ''
        layout {
            tab hide_floating_panes=true {
                pane
                pane size=1 borderless=true {
                    plugin location="compact-bar"
                }
                floating_panes {
                    pane {
                        x "5%"
                        y "5%"
                        width "90%"
                        height "90%"
                    }
                }
            }
            new_tab_template hide_floating_panes=true {
                pane
                pane size=1 borderless=true {
                    plugin location="compact-bar"
                }
                floating_panes {
                    pane {
                        x "5%"
                        y "5%"
                        width "90%"
                        height "90%"
                    }
                }
            }
        }
      '';
    };
  };
}
