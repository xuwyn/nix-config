{
  types,
  flakeInputs,
  ...
} @ adios: {
  inputs = {
    nixpkgs.from = {parent}: parent.nixpkgs;
  };

  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };
    noctaliaThemeEnabled = {
      type = types.bool;
      default = false;
    };
  };

  result = adios.promise ({
    options,
    inputs,
  }:
    (flakeInputs.nvf.lib.neovimConfiguration {
      pkgs = inputs.nixpkgs.pkgs;
      modules = [
        ./settings.nix
        ./keymaps.nix
        options.extraSettings
        ({
          pkgs,
          lib,
          ...
        }: {
          config.vim =
            if options.noctaliaThemeEnabled
            then {
              extraPlugins.base16.package = pkgs.vimPlugins.base16-nvim;

              luaConfigRC.matugen = lib.nvim.dag.entryAnywhere ''
                local dir = (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/nvim/lua"
                package.path = dir .. "/?.lua;" .. package.path

                local ok, matugen = pcall(require, "matugen")
                if ok then
                  matugen.setup()
                elseif vim.uv.fs_stat(dir .. "/matugen.lua") then
                  -- file exists but failed to load
                  vim.notify("matugen: " .. tostring(matugen), vim.log.levels.ERROR)
                end
              '';
            }
            else {
              theme = {
                enable = true;
                name = "catppuccin";
                style = "mocha";
                transparent = true;
              };
            };
        })
      ];
    }).neovim);
}
