{
  flake.modules.nixos.nfs = {...}: {
    services = {
      rpcbind.enable = true;
      nfs.server.enable = true;
    };
  };
}
