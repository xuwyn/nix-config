{
  flake.modules.homeManager.yazi = {pkgs, ...}: let
    settings = import ./_settings.nix;
    keymap = import ./_keymap.nix;
    theme = import ./_theme.nix;
  in {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      shellWrapperName = "yy";
      settings = settings;
      keymap = keymap;
      theme = theme;
      plugins = {
        lazygit = pkgs.yaziPlugins.lazygit;
        full-border = pkgs.yaziPlugins.full-border;
        git = pkgs.yaziPlugins.git;
        smart-enter = pkgs.yaziPlugins.smart-enter;
      };

      initLua = ''
        require("full-border"):setup()
           require("git"):setup()
           require("smart-enter"):setup {
             open_multi = true,
           }
      '';
    };
  };
}
