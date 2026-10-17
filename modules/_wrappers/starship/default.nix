{types, ...} @ adios: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };

    settings.default = adios.promise ({options}:
      (builtins.fromTOML (builtins.readFile ./preset.toml))
      // {scan_timeout = 250;}
      // options.extraSettings);
  };

  mutations."/zsh".extraZshrc = adios.promise ({
    inputs,
    result,
  }: let
    inherit (inputs.nixpkgs.lib) getExe;
  in ''
    eval "$(${getExe result} init zsh)"
  '');

  mutations."/bash".extraBashrc = adios.promise ({
    inputs,
    result,
  }: let
    inherit (inputs.nixpkgs.lib) getExe;
  in ''
    eval "$(${getExe result} init bash)"
  '');

  mutations."/zsh".extraPackages = adios.promise ({result}: [result]);
  mutations."/bash".extraPackages = adios.promise ({result}: [result]);
}
