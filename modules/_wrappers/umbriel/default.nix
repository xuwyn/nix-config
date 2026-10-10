{
  types,
  flakeInputs,
  ...
} @ adios: {
  inputs = {
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
    umbriel = "${options.package}/bin/umbriel";
    unitExec = ''
      ExecStart=$out/bin/umbriel -c ${configFile}
      ExecReload=$out/bin/umbriel config-replace ${configFile}
      X-ReloadIfChanged=true
      X-RestartIfChanged=false
    '';
  in
    pkgs.symlinkJoin {
      name = "wrapped-umbriel";
      paths = [options.package];
      meta = options.package.meta;
      passthru.providedSessions = ["umbriel"];
      passthru.configFile = configFile; # expose this for hjem on non-nixos
      postBuild = ''
        # replace these so display-manager can start umbriel with the right config
        rm $out/bin/start-umbriel
        substitute ${options.package}/bin/start-umbriel $out/bin/start-umbriel \
          --replace-quiet ${umbriel} "$out/bin/umbriel -c ${configFile}"
        chmod +x $out/bin/start-umbriel

        rm $out/share/systemd/user/umbriel.service
        substitute ${options.package}/share/systemd/user/umbriel.service $out/share/systemd/user/umbriel.service \
          --replace-fail "ExecStart=${umbriel}" "${unitExec}"

        rm $out/share/wayland-sessions/umbriel.desktop
        substitute ${options.package}/share/wayland-sessions/umbriel.desktop $out/share/wayland-sessions/umbriel.desktop \
          --replace-fail ${options.package}/bin/start-umbriel $out/bin/start-umbriel
      '';
    });
}
