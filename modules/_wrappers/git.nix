{types, ...}: {
  options = {
    extraSettings = {
      type = types.attrs;
      default = {};
    };

    settings.defaultFunc = {options}:
      {
        user = {
          name = "wyn";
          email = "173407133+xuwyn@users.noreply.github.com";
          signingkey = "~/.ssh/id_ed25519.pub";
        };
        core.editor = "nvim";
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
