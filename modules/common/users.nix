{
  self,
  system,
  lib,
  ...
}: let
  wm = self.wrapperModules.${system};
  isDarwin = lib.hasSuffix "-darwin" system;
in {
  programs = {
    zsh.enable = true; # default on darwin
    bash.enable = true; # default on nixos
  };
  custom.users = {
    wyn =
      {
        sshKeys = [./keys/openssh_key.pub];
        shell = lib.getExe (wm.zsh {});
      }
      // (lib.optionalAttrs (!isDarwin) {isAdmin = true;});
    deploy =
      {
        sshKeys = [./keys/deploy_key.pub];
        shell = lib.getExe (wm.bash {});
      }
      // (lib.optionalAttrs (!isDarwin) {isDeployer = true;});
  };
}
