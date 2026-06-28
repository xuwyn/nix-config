{
  flake.modules.homeManager.cli = {
    config,
    lib,
    ...
  }: let
    cfg = config.homeManager.cli.bottom;
  in {
    options.homeManager.cli.bottom = {
      enable = lib.mkEnableOption "Enable bottom";
    };
    config = lib.mkIf cfg.enable {
      programs.bottom = {
        enable = true;
        settings = {
          enable_gpu = true;
          theme = "nord";
          flags.group_processes = true;
          row = [
            {
              ratio = 2;
              child = [
                {type = "cpu";}
                {type = "temp";}
              ];
            }
            {
              ratio = 2;
              child = [
                {type = "network";}
              ];
            }
            {
              ratio = 3;
              child = [
                {
                  type = "proc";
                  ratio = 1;
                  default = true;
                }
              ];
            }
          ];
        };
      };
    };
  };
}
