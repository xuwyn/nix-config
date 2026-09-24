{types, ...}: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };

    settings.defaultFunc = {options}:
      {
        enable_gpu = true;
        theme = "nord";
        flags.processes.default_grouped = true;
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
      }
      // options.extraSettings;
  };
}
