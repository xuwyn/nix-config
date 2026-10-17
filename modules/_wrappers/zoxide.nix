adios: {
  options.flags.default = ["--cmd cd"];

  mutations."/zsh".extraZshrc = adios.promise ({
    options,
    inputs,
    result,
  }: let
    inherit (inputs.nixpkgs.lib) getExe;
    inherit (builtins) concatStringsSep;
  in ''
    eval "$(${getExe result} init zsh ${concatStringsSep " " options.flags})"
  '');

  mutations."/bash".extraBashrc = adios.promise ({
    options,
    inputs,
    result,
  }: let
    inherit (inputs.nixpkgs.lib) getExe;
    inherit (builtins) concatStringsSep;
  in ''
    eval "$(${getExe result} init bash ${concatStringsSep " " options.flags})"
  '');

  mutations."/zsh".extraPackages = adios.promise ({result}: [result]);
  mutations."/bash".extraPackages = adios.promise ({result}: [result]);
}
