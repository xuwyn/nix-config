# Remote Deployment

This file documents the procedure for remote deployment and cache push/pull to a
self-hosted Attic server.

## System Deployment

This flake uses [deploy-rs](https://github.com/serokell/deploy-rs) for remote
deployment via SSH with passwordless sudo for NixOS and nix-darwin (see
[deploy.nix](../deploy.nix) and [flake.nix](../flake.nix)). To achieve this, a
system user called `deploy` is declared on NixOS (see
[users.nix](../modules/nixos/users.nix)) and created natively on macOS (see
[mac-create-deploy-user.sh](../scripts/mac-create-deploy-user.sh)).

<details>

<summary>Some key points about <code>deploy</code> as a system user</summary>

- No user password
- Not available as a login user
- No home directory
- Only have sudo privilege for [two commands](../modules/nixos/deploy-rs.nix) to
  activate nix
- Can only be used as ssh user with correct `deploy_key`
- Belongs to `deploy` group (NixOS only)

</details>

---

**Prerequisites:**

1. **SSH Access:** Ensure an SSH connection is established between the control
   node and all target nodes. A `deploy` user must exist on target nodes with a
   trusted public key (see [users.nix](../modules/common/users.nix))

   <details>
      <summary>Add <code>deploy</code> user to MacOS</summary>

   Since adding `deploy` to nix-darwin config does not automatically create a
   new user on MacOS, run
   [mac-create-deploy-user.sh](../scripts/mac-create-deploy-user.sh) with sudo
   locally (not through SSH) to create `deploy` as a hidden user.

   Run it locally if the repo is already cloned

   ```sh
   cd ~/nix-config
   sudo ./scripts/mac-create-deploy-user.sh
   ```

   Or run it as a oneliner

   ```sh
   curl -sL https://raw.githubusercontent.com/xuwyn/nix-config/main/scripts/mac-create-deploy-user.sh \
   -o /tmp/mac-create-deploy-user.sh && \
   sudo sh /tmp/mac-create-deploy-user.sh; rm -f /tmp/mac-create-deploy-user.sh
   ```

   </details>

2. **Private Key:** The control node must have access to the private
   `deploy_key` managed by `sops-nix`

3. **Naming Convention:** `nixosConfigurations` and `darwinConfigurations` are
   keyed as their hostnames

Test the connection from the control node

```sh
ssh deploy@hostname -i ~/.ssh/deploy_key -o IdentitiesOnly=yes
```

**Deploying:**

Run `deploy-rs` directly via `nix run`

```sh
nix run github:serokell/deploy-rs ./path/to/flake/#hostname
```

Alternatively, add `deploy-rs` binary to `environment.systemPackages` so it's
always available

```sh
deploy ./path/to/flake/#hostname
```

Some helpful flags

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

## Attic Cache

This section documents how to set up
[Attic](https://docs.attic.rs/tutorial.html) as a self-host cache server in case
I have to start this from scratch again 😣

> [!Note]
>
> `atticd` is the server and `attic` is the client

**Setup Atticd on NixOS**

Add `server` tag to `nixos.hostname.tags` of the host that needs it. The traffic
is routed via tailscale with `nginx` acts as reverse proxy (see
[atticd.nix](../modules/nixos/atticd.nix)).

**Generate Atticd Credential**

Follow the [tutorial](https://docs.attic.rs/admin-guide/deployment/nixos.html)
but output it as a file for easier copy and paste

```sh
nix run nixpkgs#openssl -- genrsa -traditional 4096 | base64 -w0 > attic.b64

# Copy the content
cat attic.b64
```

Then add it to the server's sops secret in this format

```yaml
atticd_env: |
ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<content>
```

**Generate Attic Token for Clients**

Create an all encompassing token so all hosts can use it to push, pull, create
and destroy caches. This simplifies the complexity but with security trade-off.
Too bad! 🙃

> [!Note]
>
> Please generate a different token for
> [CI](../.github/workflows/push-attic-cache.yml) with just push and pull
> privileges

```sh
cd /tmp # to avoid permission error
atticd-atticadm make-token --sub "wyn" --validity "3 months" --push "*" --pull "*" \
--create-cache "*" --destroy-cache "*"
```

Then add it to `access-tokens.yaml` as `attic_token`

**Attic Client**

Attic client settings are automatically included in all `nixosConfigurations`
and `darwinConfigurations`. The default server is hosted on `puffin`. If only
one cache is used, the default `cacheName` is `main` and its `publicKey` is set
in [attic.nix](../modules/common/attic.nix).

Some relevant commands

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
sudo curl -v --netrc-file /run/secrets/rendered/.netrc https://tailnet.ts.net/main/nix-cache-info
```
