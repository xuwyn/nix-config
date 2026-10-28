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
    lib,
    ...
  }: let
    wm = self.wrapperModules.${system};

    nixglSrc = pkgs.applyPatches {
      name = "nixgl-patched";
      src = inputs.nixgl;
      postPatch = ''
        substituteInPlace nixGL.nix --replace-fail "kernel = null;" ""
      '';
    };
    nixGLPkgs = import (nixglSrc + "/default.nix") {
      inherit pkgs;
      enable32bits = false;
      nvidiaVersion = "615.78.08";
      nvidiaHash = "sha256-Pj9t3cLudnoIGFMAr3vjyyhuznZpjS3eNSRZl4LQf/4=";
    };
    nixGL = nixGLPkgs.nixGLCommon nixGLPkgs.nixGLNvidia;

    nixGLWrap = pkg:
      pkgs.symlinkJoin {
        name = "nixGL-${pkg.name}";
        paths = [pkg];
        postBuild = ''
          for f in $out/bin/*; do
            real=$(readlink -f "$f")
            rm "$f"
            printf '%s\n' \
              '#!${pkgs.runtimeShell}' \
              'export __EGL_EXTERNAL_PLATFORM_CONFIG_DIRS=${pkgs.egl-wayland}/share/egl/egl_external_platform.d' \
              'exec ${nixGL}/bin/nixGL '"$real"' "$@"' \
              > "$f"
            chmod +x "$f"
          done
        '';
      };

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
        (yazi {noctaliaThemeEnabled = true;})
        (firefox {})
        (spicetify {})
        (helix {})
        (nvf {extraSettings = {config.vim.extraPackages = with pkgs; [nodejs wl-clipboard];};})
        (nixGLWrap (kitty {noctaliaThemeEnabled = true;}))
        (nixGLWrap (sonora {noctaliaThemeEnabled = true;}))
        (nixGLWrap (noctalia {inherit desktop;}))
      ]
      ++ (with inputs; [nix-index-database.packages.${system}.comma-with-db]);
  };
}
