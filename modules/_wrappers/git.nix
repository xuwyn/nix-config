{types, ...}: {
  options = {
    sshKeyPath = {
      type = types.str;
    };
    extraSettings = {
      type = types.attrs;
      default = {};
    };

    settings.defaultFunc = {options}:
      {
        core = {
          sshCommand = "ssh -i ${options.sshKeyPath}";
          editor = "nvim";
        };
        user.signingkey = options.sshKeyPath;
        commit.gpgsign = true;
        gpg.format = "ssh";
        push.default = "simple";
        credential.helper = "cache --timeout=7200";
        init.defaultBranch = "main";
        log = {
          decorate = "full";
          date = "iso";
        };
        merge.conflictStyle = "diff3";
        pull.rebase = true;
      }
      // options.extraSettings;
  };
}
