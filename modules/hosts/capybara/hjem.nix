{
  hosts = ["capybara"];
  module = {
    self,
    pkgs,
    user,
    flake,
    system,
    inputs,
    ...
  }: let
    home = "/home/${user}";
    wm = self.wrapperModules.${system};

    desktop = {
      monitors = [
        {
          name = "DP-1";
          width = 1920;
          height = 1080;
          x = 0;
          y = 0;
          refresh = 164.955;
        }
        {
          name = "DP-4";
          width = 1920;
          height = 1080;
          x = 0;
          y = 0;
          refresh = 164.955;
        }
      ];
      terminal = "kitty";
      browser = "firefox";
      editor = "nvim";
      startupCommands = ["pkill openrgb; sleep 1; openrgb --startminimized --profile blue;"];
    };
  in {
    manifest = {
      version = 3;
      files = [
        {
          type = "symlink";
          source = (wm.umbriel {inherit desktop;}).configFile;
          target = "${home}/.config/umbriel/config.toml";
        }
        {
          type = "symlink";
          source = "${wm.noctalia {inherit desktop;}}/noctalia/noctalia.toml";
          target = "${home}/.config/noctalia/config.toml";
        }
        {
          # TODO: cant update theme in runtime with adios autogen config
          type = "copy";
          source = pkgs.writeText "kitty.conf" ''
            include ${wm.kitty {noctaliaThemeEnabled = true;}}/kitty/kitty.conf
          '';
          target = "${home}/.config/kitty/kitty.conf";
        }
        {
          type = "symlink";
          source = "${inputs.assets}/wallpapers";
          target = "${home}/Pictures/Wallpapers";
        }
        {
          type = "symlink";
          source = "${inputs.assets}/face.jpg";
          target = "${home}/.face";
        }
      ];
    };

    packages = with wm;
      [
        (zsh {
          hostZshrc = ''
            export PATH="$XDG_STATE_HOME/hjem/standalone/current-profile/bin:$PATH"
          '';
        })
        (git {})
        (tealdeer {})
        (ff {})
        (ns {})
        (cava {noctaliaThemeEnabled = true;})
        (btop {noctaliaThemeEnabled = true;})
        (yazi {})
        (firefox {})
        (nvf {extraSettings = {config.vim.extraPackages = with pkgs; [nodejs wl-clipboard];};})
      ]
      ++ (with inputs; [nix-index-database.packages.${system}.comma-with-db]);
  };
}
