_: {
  options.flags.default = [
    "--group-directories-first"
    "--no-quotes"
    "--header"
    "--git"
    "--git-ignore"
    "--icons=always"
    "--classify" # append indicator (/, *, =, @, |)
    "--hyperlink" # make paths clickable in some terminals
  ];
  mutations."/bash".extraPackages = {options}: [(options {})];
  mutations."/zsh".extraPackages = {options}: [(options {})];
}
