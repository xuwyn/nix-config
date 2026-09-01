# Remote Deployment

This file documents the procedure for remote deployment and cache push/pull to a self-hosted Attic server.

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

# Build but do not activate (reboot to activate)
deploy --boot .#hostname
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
if for some odd reasons, I decide to add anything IFD in `homeConfigurations` because `deploy-rs`
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

## Attic Cache

This section documents how to set up [Attic](https://docs.attic.rs/tutorial.html) as a self-host cache server
in case I have to start this from scratch again 😣

> [!Note]
> `atticd` is the server and `attic` is the client

**Setup Atticd on NixOS**

Import `nixos.services` and enable `nixos.services.atticd` in `nixosConfigurations`.
The traffic is routed via tailscale with `nginx` acts as reverse proxy
(see [atticd.nix](../modules/nixos/services/atticd.nix)).

**Generate Atticd Credential**

Follow the [tutorial](https://docs.attic.rs/admin-guide/deployment/nixos.html) but output
it as a file for easier copy and paste

```sh
nix run nixpkgs#openssl -- genrsa -traditional 4096 | base64 -w0 > attic.b64

# Copy the content
cat attic.b64
```

Then add it to the server's sops secret in this format:

```yaml
atticd_env: |
ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<content>
```

**Generate Attic Token for Clients**

Create an all encompassing token so all hosts can use it to push and pull.
This simplifies the complexity but with security trade-off (Too bad! 🙃)

> [!Note]
> Please generate a different token for github action with just push privilege

```sh
cd /tmp # to avoid permission error
atticd-atticadm make-token --sub "wyn" --validity "3 months" --push "*" --pull "*" \
--create-cache "*" --destroy-cache "*"
```

Then add it to `access-tokens.yaml` as `attic_token`

**Enable Attic Client**

Import `<class>.attic` into the corresponding configurations. The default server is hosted on `puffin`.
If only one cache is used, the default `cacheName` is `main` and its `publicKey` is set in [attic.nix](../modules/common/attic.nix).

Some relevant commands:

```sh
# create new cache named `main`
attic cache create main

# get cache info (including public key)
attic cache info main

# destroy a cache (does not clean cache storage)
attic cache destroy main

# push active system cache
attic push main /run/current-system

# push active home cache
attic push main $(readlink -f ~/.local/state/nix/profiles/home-manager)

# garbage collect
attic cache configure main --retention-period '3 months'
sudo atticd --mode garbage-collector-once

# Check storage size (where `atticd.settings.storage` is set)
sudo du -hs /mnt/atticd/storage

# test connection with
sudo curl -v --netrc-file /run/secrets/rendered/attic-netrc \
https://tailnet.ts.net/main/nix-cache-info

# or
curl -v --netrc-file ~/.config/sops-nix/secrets/rendered/attic-netrc \
https://tailnet.ts.net/main/nix-cache-info

```
