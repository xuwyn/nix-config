# copy from: https://github.com/llakala/adios-wrappers/blob/bb2f3db20a330104392f62c8d142ea9489c2f3b7/modules/zsh.nix
{types, ...} @ adios: {
  inputs = {
    mkWrapper.from = {parent}: parent.mkWrapper;
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    bashrc = {
      type = types.string;
      mutators = ["/bash"];
      mergeFunc = adios.lib.merge.strings.concatLines;
    };
    extraBashrc = {
      type = types.string;
      mutators = ["/bash" "/starship" "/zoxide"];
      mergeFunc = adios.lib.merge.strings.concatLines;
    };
    variables = {
      type = types.attrs;
      mergeFunc = adios.lib.merge.attrs.recursively;
      default = import ./shell/env.nix;
    };
    extraAliases = {
      type = types.attrs;
      default = {};
    };
    aliases = {
      type = types.attrsOf types.string;
      mergeFunc = adios.lib.merge.attrs.recursively;
      defaultFunc = {options}: import ./shell/aliases.nix // options.extraAliases;
    };
    extraPackages = {
      type = types.listOf types.derivation;
      mutators = ["/bash" "/eza" "/starship" "/zoxide"];
      mergeFunc = adios.lib.merge.lists.concat;
    };
    package = {
      type = types.derivation;
      defaultFunc = {inputs}: inputs.nixpkgs.pkgs.bashInteractive;
    };
  };

  mutations."/bash".extraPackages = {inputs}: [
    inputs.nixpkgs.pkgs.bash-completion
    inputs.nixpkgs.pkgs.microfetch
  ];

  mutations."/bash".bashrc = {inputs}: ''
    [ -r "${inputs.nixpkgs.pkgs.bash-completion}/etc/profile.d/bash_completion.sh" ] && \
      source "${inputs.nixpkgs.pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
  '';

  mutations."/bash".extraBashrc = _: ''
    microfetch
  '';

  impl = {
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
  in
    inputs.mkWrapper {
      inherit (options) package;
      wrapperArgs =
        if options ? extraPackages
        then "--prefix PATH : ${makeBinPath options.extraPackages}"
        else null;
      symlinks = {
        "$out/.bashrc" = writeText ".bashrc" bashrc;
      };
      flags = ["--rcfile" "$out/.bashrc"];
    };
}
