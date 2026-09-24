_: {
  options.flags.default = ["--cmd cd"];

  # copy from: https://github.com/llakala/adios-wrappers/blob/bb2f3db20a330104392f62c8d142ea9489c2f3b7/modules/zoxide.nix#L33
  mutations."/zsh".extraZshrc = {
    options,
    inputs,
  }: let
    finalWrapper = options {};
    inherit (inputs.nixpkgs.lib) getExe;
    inherit (builtins) concatStringsSep;
  in ''
    eval "$(${getExe finalWrapper} init zsh ${concatStringsSep " " options.flags})"
  '';

  mutations."/bash".extraBashrc = {
    options,
    inputs,
  }: let
    finalWrapper = options {};
    inherit (inputs.nixpkgs.lib) getExe;
    inherit (builtins) concatStringsSep;
  in ''
    eval "$(${getExe finalWrapper} init bash ${concatStringsSep " " options.flags})"
  '';

  mutations."/zsh".extraPackages = {options}: [(options {})];
  mutations."/bash".extraPackages = {options}: [(options {})];
}
