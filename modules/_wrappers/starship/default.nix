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

  # copy from: https://github.com/llakala/adios-wrappers/blob/bb2f3db20a330104392f62c8d142ea9489c2f3b7/modules/starship.nix#L71
  mutations."/zsh".extraZshrc = adios.promise ({
    options,
    inputs,
  }: let
    finalWrapper = options {};
    inherit (inputs.nixpkgs.lib) getExe;
  in ''
    eval "$(${getExe finalWrapper} init zsh)"
  '');

  mutations."/bash".extraBashrc = adios.promise ({
    options,
    inputs,
  }: let
    finalWrapper = options {};
    inherit (inputs.nixpkgs.lib) getExe;
  in ''
    eval "$(${getExe finalWrapper} init bash)"
  '');

  mutations."/bash".extraPackages = adios.promise ({options}: [(options {})]);
  mutations."/zsh".extraPackages = adios.promise ({options}: [(options {})]);
}
