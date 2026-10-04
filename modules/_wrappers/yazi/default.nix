{types, ...} @ adios: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    extraKeymap = {
      type = types.attrs;
      default = {};
    };
    extraTheme = {
      type = types.attrs;
      default = {};
    };

    settings.default = adios.promise ({options}: import ./settings.nix // options.extraSettings);
    keymap.default = adios.promise ({options}: import ./keymap.nix // options.extraKeymap);
    theme.default = adios.promise ({options}: import ./theme.nix // options.extraTheme);

    plugins.default = adios.promise ({inputs}: {
      "lazygit.yazi" = inputs.nixpkgs.pkgs.yaziPlugins.lazygit;
      "full-border.yazi" = inputs.nixpkgs.pkgs.yaziPlugins.full-border;
      "git.yazi" = inputs.nixpkgs.pkgs.yaziPlugins.git;
      "smart-enter.yazi" = inputs.nixpkgs.pkgs.yaziPlugins.smart-enter;
    });

    initLua.default = ''
      require("full-border"):setup()
      require("git"):setup()
      require("smart-enter"):setup {
        open_multi = true,
      }
    '';
  };
}
