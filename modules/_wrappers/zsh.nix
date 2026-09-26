{types, ...} @ adios: {
  options = {
    extraAliases = {
      type = types.attrs;
      default = {};
    };

    aliases.defaultFunc = {options}: import ./shell/aliases.nix // options.extraAliases;

    extraPackages.mutators = ["/eza" "/zoxide" "/starship" "/fastfetch"];

    plugins.defaultFunc = {inputs}: let
      inherit (inputs.nixpkgs) pkgs;
    in
      with pkgs; [
        zsh-autosuggestions
        zsh-history-substring-search
        zsh-syntax-highlighting
      ];

    settings.default = {
      histignoredups = true;
      histignorespace = true;
      sharehistory = true;
    };

    variables.default =
      import ./shell/env.nix
      // {
        HISTSIZE = 10000;
        SAVEHIST = 10000;
      };

    zshrc.defaultFunc = {inputs}: let
      inherit (inputs.nixpkgs) pkgs;
    in ''
      HISTFILE="$HOME/.zsh_history"
      mkdir -p "$HOME/.cache/oh-my-zsh"

      fpath=(
        ${pkgs.zsh}/share/zsh/${pkgs.zsh.version}/functions
        ${pkgs.nix-zsh-completions}/share/zsh/site-functions
        $fpath
      )

      export ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh"
      export ZSH_CACHE_DIR="$HOME/.cache/oh-my-zsh"
      ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump-$HOST-$ZSH_VERSION"
      ZSH_THEME=""
      plugins=()
      DISABLE_AUTO_UPDATE="true"
      source "$ZSH/oh-my-zsh.sh"

      # must be set before zsh-syntax-highlighting is sourced
      ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp root line)
    '';

    # copy from: https://github.com/llakala/adios-wrappers/blob/bb2f3db20a330104392f62c8d142ea9489c2f3b7/modules/nushell.nix#L16
    extraZshrc = {
      mutators = ["/zsh" "/starship" "/zoxide"];
      mergeFunc = adios.lib.merge.strings.concatLines;
    };
  };

  mutations."/zsh".extraZshrc = _: ''
    bindkey "\eh" backward-word
    bindkey "\ej" down-line-or-history
    bindkey "\ek" up-line-or-history
    bindkey "\el" forward-word

    fastfetch
  '';
}
