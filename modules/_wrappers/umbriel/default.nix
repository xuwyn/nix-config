{
  types,
  flakeInputs,
  ...
} @ adios: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    package = {
      type = types.derivation;
      default = adios.promise ({inputs}: flakeInputs.umbriel.packages.${inputs.nixpkgs.pkgs.stdenv.hostPlatform.system}.default);
    };
    desktop = {
      type = types.attrs;
      default = {};
    };
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    settings = {
      type = types.attrs;
      default = adios.promise ({
        options,
        inputs,
      }:
        import ./settings.nix {inherit (options) desktop;}
        // {
          window_rule = import ./windowrules.nix;
          animation = import ./animation.nix;
          environment = import ./environment.nix {
            inherit (options) desktop;
          };
          keybinds = import ./keybinds.nix {
            inherit (options) desktop;
            inherit (inputs.nixpkgs) lib;
          };
        }
        // options.extraSettings);
    };
  };
  result = adios.promise ({
    options,
    inputs,
  }: let
    pkgs = inputs.nixpkgs.pkgs;
    configFile = (pkgs.formats.toml {}).generate "umbriel-config.toml" options.settings;

    # Use shell script to start umbriel instead of wrapping it with just -c flag
    # so that `umbriel` can still work like a normal cli
    wrapped-umbriel = pkgs.writeShellScript "umbriel" ''
      case "''${1:-}" in
        "") exec ${options.package}/bin/umbriel -c ${configFile} ;;
        -s) exec ${options.package}/bin/umbriel "$@" -c ${configFile} ;;
        *) exec ${options.package}/bin/umbriel "$@" ;;
      esac
    '';
  in
    # replace umbriel in start-umbriel, umbriel.service and umbriel.desktop with wrapped-umbriel
    pkgs.symlinkJoin {
      name = "wrapped-umbriel";
      paths = [options.package];
      meta = options.package.meta;
      passthru.providedSessions = ["umbriel"];
      postBuild = ''
        rm $out/bin/umbriel
        ln -s ${wrapped-umbriel} $out/bin/umbriel

        rm $out/bin/start-umbriel
        substitute ${options.package}/bin/start-umbriel $out/bin/start-umbriel --replace-quiet ${options.package}/bin/umbriel $out/bin/umbriel
        chmod +x $out/bin/start-umbriel

        rm $out/share/systemd/user/umbriel.service
        substitute ${options.package}/share/systemd/user/umbriel.service $out/share/systemd/user/umbriel.service --replace-fail ${options.package}/bin/umbriel $out/bin/umbriel

        rm $out/share/wayland-sessions/umbriel.desktop
        substitute ${options.package}/share/wayland-sessions/umbriel.desktop $out/share/wayland-sessions/umbriel.desktop --replace-fail ${options.package}/bin/start-umbriel $out/bin/start-umbriel
      '';
    });
}
