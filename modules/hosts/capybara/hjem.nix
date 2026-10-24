{
  hjemCompat = true;
  targets = ["capybara"];
  module = {
    self,
    pkgs,
    user,
    flake,
    system,
    inputs,
    ...
  }: let
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
    hj.xdg.config.files = {
      "umbriel/config.toml".source =
        (wm.umbriel {
          inherit desktop;
          extraKeybinds = {
            "Mod+D" = "spawn:vesktop";
          };
        }).configFile;

      # this pulls another copy of noctalia (not just the config) 😑
      "noctalia/config.toml".source = "${wm.noctalia {inherit desktop;}}/noctalia/noctalia.toml";

      "kitty/kitty.conf" = {
        type = "copy"; # cant update its theme in runtime if symlink
        text = ''
          include ${wm.kitty {noctaliaThemeEnabled = true;}}/kitty/kitty.conf
        '';
      };
    };

    hj.packages = with wm;
      [
        (zsh {
          hostZshrc = ''
            export PATH="''${XDG_STATE_HOME:-$HOME/.local/state}/hjem/standalone/current-profile/bin:$PATH"
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
        (spicetify {})
        (nvf {extraSettings = {config.vim.extraPackages = with pkgs; [nodejs wl-clipboard];};})
      ]
      ++ (with inputs; [nix-index-database.packages.${system}.comma-with-db]);
  };
}
