# Remote Deployment

This file documents the procedure for remote deployment between hosts.

## System Deployment

This flake uses [deploy-rs](https://github.com/serokell/deploy-rs) for remote deployment via SSH with
passwordless sudo for NixOS and nix-darwin (see [deploy.nix](../deploy.nix) and [flake.nix](../flake.nix)).
To achieve this, a system user called `deploy` is declared on NixOS (see [users.nix](../modules/common/users.nix))
and created natively on macOS (see [mac-create-deploy-user.sh](../scripts/mac-create-deploy-user.sh)).

<details>

<summary>Some key points about <code>deploy</code> as a system user</summary>

- No user password
- Not available as a login user
- No home directory
- Only have sudo privilege for [two commands](../modules/common/deploy.nix) to activate nix
- Can only be used as ssh user with correct `deploy_key`
- Belongs to `deploy` group (NixOS only)

</details>

---

**Prerequisites:**

1. **SSH Access:** Ensure an SSH connection is established between the control node and all target nodes.
   A `deploy` user must exist on target nodes with a trusted public key (see [users.nix](../modules/common/users.nix))

      <details>
      <summary>Add <code>deploy</code> user to NixOS</summary>

   ```nix
   {config, ...}: {
     nixos.host1 = {
       system = "x86_64-linux";
       users = ["nixos" "deploy"];
       modules = with config.modules.nixos;
         [nix-settings system sops tailscale deploy users network security]
         ++ [
           {
             nixos.users = {
               nixos = {
                 isAdmin = true;
                 sshKeys = [../../common/keys/openssh_key.pub];
               };
               deploy = {
                 isDeployer = true;
                 sshKeys = [../../common/keys/deploy_key.pub];
               };
             };
           }
         ];
     };
   }
   ```

      </details>

      <details>
      <summary>Add <code>deploy</code> user to nix-darwin</summary>

   ```nix
   {config, ...}: {
     darwin.host2 = {
       users = ["darwin" "deploy"];
       modules = with config.modules.darwin;
         [nix-settings system sops tailscale deploy users network security]
         ++ [
           {
             darwin.users = {
               darwin.sshKeys = [../../common/keys/openssh_key.pub];
               deploy.sshKeys = [../../common/keys/deploy_key.pub];
             };
           }
         ];
     };
   }
   ```

   Since adding `deploy` to nix-darwin config does not automatically create a new user on MacOS,
   run [mac-create-deploy-user.sh](../scripts/mac-create-deploy-user.sh) with sudo locally (not through SSH)
   to create `deploy` as a hidden user.

   Run it locally if the repo is already cloned:

   ```sh
   cd ~/nix-config
   sudo ./scripts/mac-create-deploy-user.sh
   ```

   Or run it as a oneliner:

   ```sh
   curl -sL https://raw.githubusercontent.com/xuwyn/nix-config/main/scripts/mac-create-deploy-user.sh \
   -o /tmp/mac-create-deploy-user.sh && \
   sudo sh /tmp/mac-create-deploy-user.sh; rm -f /tmp/mac-create-deploy-user.sh
   ```

      </details>

2. **Private Key:** The control node must have access to the private `deploy_key` managed by
   `homeManager.sops` (can be found at `~/.config/sops-nix/secrets/deploy_key` by `sops-nix` default)

3. **Naming Convention:** `nixosConfigurations` and `darwinConfigurations` are keyed as their hostnames

Test the connection with:

```sh
ssh deploy@hostname -i ~/.config/sops-nix/secrets/deploy_key -o IdentitiesOnly=yes
```

**Deploying:**

> [!NOTE]
> `profile` can be `nixos` or `darwin` or `home`. Drop `profile` to deploy all profiles applicable to that `hostname`

Run `deploy-rs` directly via `nix run`:

```sh
nix run github:serokell/deploy-rs ./path/to/flake/#hostname.profile
```

Alternatively, add `deploy-rs` binary to `home.packages` (see [common/deploy.nix](../modules/common/deploy.nix))
or `environment.systemPackages` so it's always available:

```sh
deploy ./path/to/flake/#hostname.profile
```

Some helpful flags:

```sh
cd path/to/flake

# Skip flake check for matched platform targets
# (can take forever, especially after `nh clean all`)
deploy --skip-checks .#hostname

# Deploy multiple nodes at once
deploy --targets .#hostname1 .#hostname2 .#hostname3

# Override default target hostname (defaults to target config name)
# Useful if MagicDNS (tailscale) or mDNS isn't configured:
deploy .#hostname --hostname hostname.local

# Print debug log to terminal
deploy --debug-logs .#hostname
```

## Home Deployment

There are two ways to deploy home configurations for this flake, via `deploy-rs` or using a custom shell script
[deploy-home.sh](../scripts/deploy-home.sh) (Thank [brokenpip3](https://github.com/brokenpip3/my-binaries/blob/main/productivity/nix-specific/home-manager-remote/home-manager-remote.sh)!).
For most cases, `deploy-rs` alone is sufficient but in some, the less restrictive custom script may
be easier to use, especially when dealing with MacOS 😖

---

**Prerequisites:**

1. **SSH Access:** SSH connection is established between the main node and target node for the user with
   Home Manager profile (see [home/ssh.nix](../modules/home/ssh.nix))
2. **(MacOS-Only) Home Activate:** A system service to auto-activate Home Manager on the target node upon login,
   in case the initial activation fails due to user session being inactive (e.g., user is logout)
   (see [common/deploy.nix](../modules/common/deploy.nix))
3. **Naming Convention:** `homeConfigurations` is keyed as `username@hostname`

**Deploying:**

> [!WARNING]
> `mkOutOfStoreSymlink` will not work properly if the target node does not already have a local copy
> of the flake at the expected path. Any changes made to those symlinked files on the control node's flake
> (or in the remote repo) will **NOT** be applied to the target node.

**_Via `deploy-rs`_**

```sh
deploy .#hostname.home
```

The newly built Home Manager profile may not be successfully activated if no user session is found
(i.e., the user is logout) on MacOS. Hence, `deploy-rs` would throw errors and try to reactivate the
old profile if `autoRollback` and `magicRollback` are enabled (by default). Disabling rollback to keep
the new profile and let other service handles Home manager activation at login.

```sh
deploy --auto-rollback false --magic-rollback false .#hostname.home
```

**_Via custom script_**

Use this custom script ([deploy-home.sh](../scripts/deploy-home.sh)) for cross-platform deployment
if for some odd reasons, I decide to add anything IDF in `homeConfigurations` because `deploy-rs`
will fail at eval stage (see [TROUBLESHOOT](./TROUBLESHOOT.md#avoid-ifd-for-remote-deployment)).
The trade-offs are the ability to deploy multiple nodes/profiles at once and the `autoRollback`&`magicRollback` features.

Run it locally:

```sh
cd ~/nix-config

# path/to/flake can be a local path or a remote git repo
# use --build-on-target for cross-platform deployment
./scripts/deploy-home.sh ./path/to/flake username@hostname [--build-on-target]
```

Or run it as a oneliner:

```sh
sh <(curl -L https://raw.githubusercontent.com/xuwyn/nix-config/main/scripts/deploy-home.sh) \
./path/to/flake username@hostname [--build-on-target]
```
