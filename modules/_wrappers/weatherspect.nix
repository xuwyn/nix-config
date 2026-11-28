{
  types,
  promise,
  flakeInputs,
  ...
}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    configContents = {
      type = types.string;
      description = "Contents of the weatherspect config file, passed via `-f`.";
      default = ''
        # use ansi color (0 = no, 1 = yes)
        color: 1

        # run in debug mode (0 = no, 1 = yes)
        debug: 0

        # Units format ( metric or imperial )
        display_units: metric

        # how many random things to animate at once
        entities: 5

        # how long (in seconds) to sleep between frames
        frame_delay: 0.1

        # City / City, State / City, Country / Country
        location: New York

        # how often (in seconds) to attempt to retrieve weather data
        retr_interval: 600

        # how long (in seconds) trees should live
        tree_lifespan: 3600

        # the version of weatherspect this config was generated with
        version: 2.00
      '';
    };

    package = {
      type = types.derivation;
      description = "The weatherspect package to be wrapped.";
      default = promise ({inputs}: let
        pkgs = inputs.nixpkgs.pkgs;
        perl = pkgs.perl.withPackages (p:
          with p; [
            TermAnimation
            Curses
            LWPProtocolHttps
          ]);
      in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "weatherspect";
          version = "2.0";
          src = flakeInputs.weatherspect;

          buildInputs = [perl];
          dontBuild = true;

          installPhase = ''
            install -Dm755 weatherspect $out/bin/weatherspect
          '';

          meta.mainProgram = "weatherspect";
        });
    };
  };

  inputs.mkWrapper.options = promise (
    {
      options,
      inputs,
    }: {
      inherit (options) package;
      symlinks."$out/weatherspect/config" = inputs.nixpkgs.pkgs.writeText "weatherspect.conf" options.configContents;
      flags = [
        "-f"
        "$out/weatherspect/config"
      ];
    }
  );

  result = promise ({results}: results.mkWrapper);
}
