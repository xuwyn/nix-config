# Troubleshoot

This file documents my troubleshooting results via trial and error.
Most problems usually stem from either NVIDIA driver or trying to run nix on non-nix system 😭

## NixOS Recovery

**Usage:** to manually recover from cases where reformatting drive and/or reinstalling NixOS is unnecessary
(e.g., freezing on boot or user password failing to authenticate).

> [!NOTE]
> This script ([recover.sh](../scripts/recover.sh)) will mount the LUKS-encrypted NixOS
> and try to rebuild it with a chosen flake (can be either local or from a remote repo).

Boot into an external drive running any distro with Nix installed and run this oneliner:

```sh
sh <(curl -L https://raw.githubusercontent.com/xuwyn/nix-config/main/scripts/recover.sh)
```

If on a distro without `nixos-install`, execute the oneliner in a nix shell:

```sh
nix shell nixpkgs#nixos-install-tools --command sh <(curl -L https://raw.githubusercontent.com/xuwyn/nix-config/main/scripts/recover.sh)
```

## NVIDIA Shenanigans

- Use open-sourced driver for RTX 50xx (see [nvidia.nix](../modules/nixos/drivers/nvidia.nix))
- Use `offload` mode for laptop with NVIDIA GPU
- Use `sync` mode for desktop with NVIDIA GPU
- Standalone Home Manager running on non-NixOS Linux hosts with NVIDIA GPU
  should enable `targets.genericLinux.gpu.nvidia`

  ```nix
  # example for _gpu.nix
  { lib, ... }: {
    nixpkgs.config.nvidia.acceptLicense = true;
    targets = {
      genericLinux = {
        enable = true;
        gpu = {
          enable = true;
          nvidia = {
            enable = true;
            # Run `nvidia-smi` to get the exact driver version
            version = "595.71.05";
            # Run `home-manager switch` once to get the actual hash then replace it here
            sha256 = lib.fakeHash;
          };
        };
      };
    };
  }
  ```

## Fix `pkg-config` on Non-NixOS

When Nix is installed on a non-NixOS host, it puts its own path at the beginning of `$PATH`.
This leads to errors running updates with the host's native package manager (e.g., `apt`, `yay`, etc.)
because the nix version of `pkg-config` points to the `nix-store` instead of the host system.

**Arch-based distros**

Because AUR helpers like `yay` and `paru` rely on `makepkg` (from `pacman`) to compile packages:

```sh
mkdir -p ~/.config/pacman
echo 'PKG_CONFIG_PATH="/usr/lib/pkgconfig:/usr/share/pkgconfig"' >> ~/.config/pacman/makepkg.conf
```

## Fix PAM on Non-NixOS

If any package requiring PAM, such as Noctalia or DankMaterialShell (to unlock lockscreen for instance), is installed
via Home Manager on a non-NixOS, there's a high chance it will fail to find the correct path to the native `unix_chkpwd`
(cause it looks for the Nix-specific path `/run/wrappers/bin/unix_chkpwd` instead).

The solution is to symlink the native `unix_chkpwd` to the expected Nix path and create a systemd tmpfiles config
in `/etc/tmpfiles.d/` so the fix persists across reboots (see [fix-nix-pam.sh](../scripts/fix-nix-pam.sh))

> [!WARNING]
> This script **should** fix this issue across most non-NixOS distros for most packages installed via Home Manager,
> but I have only tested this on CachyOS with DankMaterialShell.

Run it locally with sudo:

```sh
cd /path/to/flake
sudo ./scripts/fix-nix-pam.sh
```

Or use this oneliner to download the script, execute and then delete it:

```sh
curl -sL https://raw.githubusercontent.com/xuwyn/nix-config/main/scripts/fix-nix-pam.sh -o /tmp/fix.sh && \
sudo sh /tmp/fix.sh; rm -f /tmp/fix.sh
```

## Avoid IFD for Remote Deployment

[deploy-rs](https://github.com/serokell/deploy-rs) cannot deploy configurations with
[IFD](https://nix.dev/manual/nix/2.35/language/import-from-derivation#illustration) (build-during-eval)
across different platforms (even with `remoteBuild` enabled) since it always runs `nix eval`
locally before building remotely (the local eval can't produce a derivation for a different platform).

At the time of writing this (2026/08/13), the only module with IFD in my config is [matugen](https://github.com/InioX/matugen). The module
[builds a theme file](https://github.com/InioX/matugen/blob/133e410751c7c484a9fdddc299851d4494e59871/module.nix#L91-L110)
and [reads its output back in with `builtins.readFile`](https://github.com/InioX/matugen/blob/133e410751c7c484a9fdddc299851d4494e59871/module.nix#L112)
to populate `programs.matugen.theme.colors`, forcing the build to happen _during evaluation_ rather than at
build/switch time. Unfortunately, `theme.colors` is embedded in quite a few of my apps and features, hence patching the module
(rather than a major refactoring) is the easier option.

The patch works by adding another option, `cachedThemeFile`, to populate `programs.matugen.theme.colors`
with a pre-generated theme file (see [\_patched-module.nix](../modules/home/theme/matugen/_patched-module.nix)).
To apply the patch, the upstream [module.nix](https://github.com/InioX/matugen/blob/133e410751c7c484a9fdddc299851d4494e59871/module.nix)
is disabled and the patched module (as a local copy) is imported (see [matugen/default.nix](../modules/home/theme/matugen/default.nix)).
It is done this way to avoid using IFD to patch an imported module, which defeats the whole purpose of the patch in the first place.

```nix
# matugen/default.nix
imports = [
  ({inputs, ...}: {
    disabledModules = ["${inputs.matugen}/module.nix"];
    imports = [(import ./_patched-module.nix inputs.matugen)];
  })
];
```
