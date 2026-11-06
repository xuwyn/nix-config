# copy from: https://github.com/llakala/adios-wrappers/blob/bb2f3db20a330104392f62c8d142ea9489c2f3b7/modules/zsh.nix
{
  types,
  merge,
  ...
} @ adios: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    bashrc = {
      type = types.string;
      mutators = ["/bash"];
      mergeFunc = merge.strings.concatLines;
    };
    extraBashrc = {
      type = types.string;
      mutators = ["/bash" "/zoxide"];
      mergeFunc = merge.strings.concatLines;
    };
    variables = {
      type = types.attrs;
      mergeFunc = merge.attrs.recursively;
    };
    extraAliases = {
      type = types.attrs;
      default = {};
    };
    aliases = {
      type = types.attrsOf types.string;
      mergeFunc = merge.attrs.recursively;
      default = adios.promise ({options}: import ./shell/aliases.nix // options.extraAliases);
    };
    extraPackages = {
      type = types.listOf types.derivation;
      mutators = ["/bash" "/eza" "/zoxide"];
      mergeFunc = merge.lists.concat;
    };
    package = {
      type = types.derivation;
      default = adios.promise ({inputs}: inputs.nixpkgs.pkgs.bashInteractive);
    };
  };

  mutations."/bash".extraPackages = adios.promise ({inputs}: [
    inputs.nixpkgs.pkgs.bash-completion
  ]);

  mutations."/bash".bashrc = adios.promise ({inputs}: ''
    [ -r "${inputs.nixpkgs.pkgs.bash-completion}/etc/profile.d/bash_completion.sh" ] && \
      source "${inputs.nixpkgs.pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
  '');

  mutations."/bash".extraBashrc = ''
    ${import ./shell/env.nix}
  '';

  inputs.mkWrapper.options = adios.promise ({
    options,
    inputs,
  }: let
    inherit (inputs.nixpkgs.pkgs) writeText;
    inherit (inputs.nixpkgs.lib) makeBinPath optionalString;
    inherit (builtins) concatStringsSep attrNames;
    mapAndConcat = func: elems: (concatStringsSep "\n" (map func elems)) + "\n";

    bashrcText = optionalString (options ? bashrc) "${options.bashrc}\n";
    extraBashrcText = optionalString (options ? extraBashrc) "${options.extraBashrc}\n";
    variables = optionalString (options ? variables) (
      mapAndConcat (name: "export ${name}=${toString options.variables.${name}}")
      (attrNames options.variables)
    );
    aliases = optionalString (options ? aliases) (
      mapAndConcat (name: "alias ${name}='${options.aliases.${name}}'")
      (attrNames options.aliases)
    );

    bashrc =
      bashrcText
      + variables
      + aliases
      + extraBashrcText;
  in {
    inherit (options) package;
    wrapperArgs =
      if options ? extraPackages
      then "--prefix PATH : ${makeBinPath options.extraPackages}"
      else null;
    symlinks = {
      "$out/.bashrc" = writeText ".bashrc" bashrc;
    };
    flags = ["--rcfile" "$out/.bashrc"];
  });

  result = adios.promise ({results}: results.mkWrapper);
}
