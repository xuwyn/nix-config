{
  hjemCompat = true;
  targets = ["capybara"];
  module = {
    config,
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

    zeditor = nixGLWrap (wm.zeditor {noctaliaThemeEnabled = true;});
    kitty = nixGLWrap (wm.kitty {noctaliaThemeEnabled = true;});
    sonora = nixGLWrap (wm.sonora {noctaliaThemeEnabled = true;});
    noctalia = nixGLWrap (wm.noctalia {inherit (config.custom) desktop;});
    mpv = nixGLWrap (wm.mpv {});
    swayimg = nixGLWrap (wm.swayimg {});
    cressida = nixGLWrap inputs.cressida.packages.${system}.default;
  in {
    custom.desktop = {
      monitors = map (name: {
        inherit name;
        width = 1920;
        height = 1080;
        x = 0;
        y = 0;
        refresh = 164.955;
      }) ["DP-1" "DP-4"];
      startupCommands = ["pkill openrgb; sleep 1; openrgb --startminimized --profile blue;"];
    };

    hj.xdg.config.files = {
      "umbriel/config.toml".source = (wm.umbriel {inherit (config.custom) desktop;}).configFile;
    };

    hj.xdg.data.files = let
      linkDesktop = pkg: name: {
        "applications/${name}".source = "${pkg}/share/applications/${name}";
      };
    in
      linkDesktop zeditor "dev.zed.Zed.desktop"
      // linkDesktop mpv "mpv.desktop"
      // linkDesktop swayimg "swayimg.desktop";

    hj.packages = with wm; [
      (cava {noctaliaThemeEnabled = true;})
      (btop {noctaliaThemeEnabled = true;})
      (yazi {noctaliaThemeEnabled = true;})
      (firefox {})
      (spicetify {})
      (helix {})
      (nvf {extraSettings = {config.vim.extraPackages = with pkgs; [nodejs wl-clipboard];};})
      (ff {})
      zeditor
      kitty
      sonora
      noctalia
      mpv
      swayimg
      cressida
    ];
  };
}
