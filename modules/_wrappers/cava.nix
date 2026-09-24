{types, ...}: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    settings = {
      type = types.attrs;
      description = "Nixified config";
    };
    configFile = {
      type = types.pathLike;
      description = "Path to config file (INI)";
    };
    theme = {
      type = types.string;
      default = "";
      description = "Empty string falls back to Catppuccin";
    };
    package = {
      type = types.derivation;
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.cava;
    };
  };

  options.settings.defaultFunc = {
    options,
    inputs,
  }: let
    isDarwin = inputs.nixpkgs.pkgs.stdenv.hostPlatform.isDarwin;
  in {
    input =
      if isDarwin
      then {
        method = "portaudio";
        source = "BlackHole 2ch";
      }
      else {};

    general = {
      bar_spacing = 1;
      bar_width = 2;
      frame_rate = 60;
    };

    color =
      if options.theme != ""
      then {theme = options.theme;}
      else {
        gradient = 1;
        gradient_color_1 = "'#8bd5ca'";
        gradient_color_2 = "'#91d7e3'";
        gradient_color_3 = "'#7dc4e4'";
        gradient_color_4 = "'#8aadf4'";
        gradient_color_5 = "'#c6a0f6'";
        gradient_color_6 = "'#f5bde6'";
        gradient_color_7 = "'#ee99a0'";
        gradient_color_8 = "'#ed8796'";
      };
  };
  impl = {
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeText;
    inherit (inputs.nixpkgs.lib) optionals optionalString;
    generator = inputs.nixpkgs.pkgs.formats.ini {};

    configFileText = optionalString (options ? configFile) (builtins.readFile options.configFile + "\n");
    settingsText = optionalString (options ? settings) (builtins.readFile (generator.generate "config" options.settings));

    configPath = writeText "config" (configFileText + settingsText);
  in
    inputs.mkWrapper {
      inherit (options) package;
      flags = optionals (options ? configFile || options ? settings) ["-p" "${configPath}"];
    };
}
